---
title: Working with External Services in Nest.js
---

At its core, [Nest.js][nest] provides a robust[ dependency injection][di]
[system][nest-di] for resolving dependencies within your application. While a
typical use case might be to inject a database connection into any service
classes that need it, where this can really shine is when your application
relies on one or more external service(s).

A solution that we often employ in this situation looks like the following:

1. Create a TypeScript interface that provides an ergonomic surface area for how
   we want to interact with the external service
1. Create concrete classes that implement this interface that we can use in both
   a local development environment and a remote production environment
1. Create a referenceable service token that can be used to inject the right
   dependency as needed
1. Create a service fake that implements the above interface that can be
   injected for use in our end-to-end (e2e) tests

## In Practice

A server-side application will typically need to send email, so let's think
about how that looks in its simplest form. As promised, we'll tackle the
interface first:

```ts
type Message = {
  from: string;
  to: string;
  subject: string;
  body: string;
};

interface Mailer {
  send(message: Message): Promise<void>;
}
```

Now we can introduce some concrete classes that implement this interface. First,
we'll start with a class that will _actually_ send an email through an SMTP
relay (using [nodemailer][nodemailer]):

```ts
type SMTPMailerOptions = {
  host: string;
  username: string;
  password: string;
};

class SMTPMailer implements Mailer {
  protected readonly transport: ReturnType<typeof createTransport>;

  constructor(options: SMTPMailerOptions) {
    this.transport = createTransport({
      host: options.host,
      auth: {
        user: options.username,
        pass: options.password,
      },
    });
  }

  async send(message: Message): Promise<void> {
    await this.transport.sendMail({
      from: message.from,
      to: message.to,
      subject: message.subject,
      text: message.body,
    });
  }
}
```

And a corresponding class that will satisfy this interface but will log the
message rather than attempting delivery:

```ts
class LoggingMailer implements Mailer {
  send(message: Message): Promise<void> {
    return Promise.resolve(console.info(JSON.stringify(message)));
  }
}
```

## Injecting Our Dependency

In order to use these mailer classes, we now need to make Nest's dependency
injection system aware of them. Because we're not providing a concrete class
(we'll be using our `Mailer` interface), we need to specify a service token that
can be resolved to an instance of a `Mailer` class.

The service token can be a string, but I like taking the extra step of creating
a [TypeScript `enum`][string-enum] to make things less error-prone:

```ts
enum ServiceTokens {
  Mailer = "SERVICE_TOKENS_MAILER",
}
```

Now, we can register our mailer as a provider -- I like the
[`useFactory` approach][factory-providers] for most cases:

```ts
// app.module.ts

@Module({
  providers: [
    {
      provide: ServiceTokens.Mailer,
      useFactory: (): Mailer => {
        const env = process.env.NODE_ENV || "development";

        if (["development", "test"].includes(env)) {
          return new LoggingMailer();
        }

        // Typically, this configuration would come
        // from external environment variables
        return new SMTPMailer({
          host: "smtp.relay",
          username: "admin",
          password: "d34db33f",
        });
      },
    },
  ],
})
export class AppModule {}
```

So ... in our local environments we'll simply log all email messages, otherwise
we will try to send through the configured SMTP server.

> The credentials in this example are hard-coded but you'll definitely want to
> pull this configuration from your environment. The official
> [Nest documentation][nest-config] is a good place to research approaches.

## Putting it All Together

Now that we've registered our mailer as a provider, we can inject it anywhere
we need to. Let's put together a simple controller that will send a message to
a target recipient:

```ts
class Recipient {
  email: string;
}

@Controller("notifications")
@Injectable()
export class NotificationsController {
  constructor(
    @Inject(ServiceTokens.Mailer) protected readonly mailer: Mailer
  ) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  async notify(@Body() recipient: Recipient) {
    await this.mailer.send({
      from: "noreply@host.example",
      to: recipient.email,
      subject: "Notification",
      body: "You have been notified!",
    });

    return { status: "ok" };
  }
}
```

Make sure to add the controller to your `AppModule`:

```ts
// app.module.ts

@Module({
  controllers: [NotificationsController],
  // ...
})
export class AppModule {}
```

You should now be able to boot your app with `yarn start:dev` and use
[cURL][curl] to initiate a message send:

```
curl -s \
  -H "Content-Type: application/json" \
  -d '{"email":"user@host.example"}' \
  "http://localhost:3000/notifications" | python -m json.tool
```

You should see a response of `{"status": "ok"}` and see a message printed to the
Nest.js console:

```
{"from":"noreply@host.example","to":"user@host.example","subject":"Notification","body":"You have been notified!"}
```

## Bonus: Adding a Fake for E2E Testing

We've already guarded against accidentally sending emails in our test
environment, but what about when we want to assert whether or not an email was
sent from our application? An approach that I prefer over using a tool like
[`jest.spyOn()`][jest-spy-on] is to introduce a
[lightweight fake][fakes-over-mocks].

We can again rely on the initial interface definition to help define our fake:

```ts
class MailerFake implements Mailer {
  lastMessage?: Message;

  send(message: Message): Promise<void> {
    this.lastMessage = message;
    return Promise.resolve();
  }

  clear(): void {
    this.lastMessage = undefined;
  }
}
```

Swapping out our mailer at test time is as easy as using `overrideProvider()`
when creating our testing module:

```ts
// test/notifications.e2e-spec.ts

describe("Notifications (e2e)", () => {
  let app: INestApplication;
  let mailer: MailerFake;

  beforeAll(async () => {
    mailer = new MailerFake();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(ServiceTokens.Mailer)
      .useValue(mailer)
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => await app.close());

  // prevent pollution between tests
  afterEach(() => mailer.clear());

  it("sends an email to the specified recipient", async () => {
    const { body, status } = await request(app.getHttpServer())
      .post("/notifications")
      .send({ email: "user@host.example" });

    expect(body).toEqual({ status: "ok" });
    expect(status).toBe(HttpStatus.OK);

    expect(mailer.lastMessage).toEqual({
      from: "noreply@host.example",
      to: "user@host.example",
      subject: "Notification",
      body: "You have been notified!",
    });
  });
});
```

Now we have a robust solution that sends mail when we want, doesn't send mail
when we don't want, and allows us to have confidence that our application was
doing the right thing the whole time.

---

_This article was originally posted on the [KindHealth engineering blog][source]._

[nest]: https://docs.nestjs.com/
[di]: https://en.wikipedia.org/wiki/Dependency_injection
[nest-di]: https://docs.nestjs.com/providers#dependency-injection
[nodemailer]: https://nodemailer.com/about/
[string-enum]: https://www.typescriptlang.org/docs/handbook/enums.html#string-enums
[factory-providers]: https://docs.nestjs.com/fundamentals/custom-providers#factory-providers-usefactory
[nest-config]: https://docs.nestjs.com/techniques/configuration
[curl]: https://curl.se/
[jest-spy-on]: https://jestjs.io/docs/jest-object#jestspyonobject-methodname
[fakes-over-mocks]: https://tyrrrz.me/blog/fakes-over-mocks
[source]: https://archive.today/PAoJ0
