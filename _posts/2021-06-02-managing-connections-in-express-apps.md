---
title: Managing Connections in Express Apps
---

Typically when building apps in [Express][1] you'll be using some sort of
persistence mechanism, whether that is a relational database, NoSQL database, or
another object store. Certain circumstances require using two stores
simultaneously, perhaps if you want to use an RDBMS as a source of truth but
leverage something like [Redis][2] as a cache to boost overall performance.
Whatever technology you're using in your application, you'll want to ensure that
connections are established (or have failed fast) before you fully boot your
app.

Introductory tutorials often take the approach of initializing the database
connection independently from booting the Express app -- [this tutorial][3] is a
top result but there are many like it. The typical approach is as follows (we're
using [Sequelize][4] with [sqlite][5] here):

```ts
const app = express();
app.use(express.json());

sequelize
  .authenticate()
  .then(() => {
    console.log("Database connection established");
  })
  .catch((err) => {
    console.log(`Connection failed: ${err}`);
  });

app.get("/users", async (_, resp) => {
  const users = await User.findAll(); // User is a Sequelize model
  resp.status(200).json({ users });
});

app.listen(3000, () => {
  console.log("Listening on port 3000");
});
```

The problem may not be obvious, but we've created a situation where 2 unintended
outcomes are possible:

1. Requests to the `/users` endpoint return no data because a request is made
   before the database connection is established
1. The connection to the database fails, but the application starts in a broken
   state (requests to `/users` hang since the database is unavailable)

We can handle the second scenario by exiting the process when the database
connection fails, but there could be a period of time where the app starts
handling requests waiting for the connection to finally time out.

Fortunately, there are a couple of solutions to ensure that the application
starts in a valid state.

## Wait for the Connection Promise to Resolve

What might be the quickest solution is to move the "listen" operation inside of
the resolved promise after the connection is established:

```ts
app.get("/users", async (_, resp) => {
  const users = await User.findAll(); // User is a Sequelize model
  resp.status(200).json({ users });
});

sequelize
  .authenticate()
  .then(() => {
    console.log("Database connection established");

    app.listen(3000, () => {
      console.log("Listening on port 3000");
    });
  })
  .catch((err) => {
    console.error(`Connection failed: ${err}`);
    process.exit(1);
  });
```

This way, the application will only be available once the database connection is
available, and the `process.exit` call will ensure that the process exits with
an error status for anything monitoring it. This can also be accomplished using
`async` / `await`:

```ts
(async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connection established");
  } catch (e) {
    console.error(e);
    process.exit(1);
  }

  app.listen(3000, () => {
    console.log("Listening on port 3000");
  });
})();
```

## Use Node's Built-In Event Handling

Node supports an [event-driven architecture][6] at its core, and Express builds
on these core capabilities. Inspired by [this blog post][7], we can adopt an
approach that listens for events before starting the server:

```ts
app.get("/users", async (_, resp) => {
  const users = await User.findAll(); // User is a Sequelize model
  resp.status(200).json({ users });
});

app.once("connected", () => {
  app.listen(3000, () => {
    console.log("Listening on port 3000");
  });
});

sequelize
  .authenticate()
  .then(() => {
    console.log("Database connection established");
    app.emit("connected");
  })
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
```

Similar to the previous example, the app will only boot once the event has been
emitted. Though this could result in some disconnect between the strings used in
the event handlers, that can be easily mitigated using a TypeScript `enum`:

```ts
enum Events {
  Connected = "connected",
}

app.once(Events.Connected, () => {
  app.listen(3000, () => {
    console.log("Listening on port 3000");
  });
});

sequelize
  .authenticate()
  .then(() => {
    console.log("Database connection established");
    app.emit(Events.Connected);
  })
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
```

Again, it's possible to use `async` / `await` semantics:

```ts
(async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connection established");
  } catch (e) {
    console.error(e);
    process.exit(1);
  }

  app.emit(Events.Connected);
})();
```

Both of these approaches provide a cleaner way to ensure that your Express
applications boot successfully or fail fast.

---

_This article was originally posted on the [KindHealth engineering blog][8]._

[1]: http://expressjs.com/
[2]: https://redis.io/
[3]: https://stackabuse.com/using-sequelize-orm-with-nodejs-and-express
[4]: https://sequelize.org/
[5]: https://sqlite.org/index.html
[6]: https://nodejs.org/docs/latest-v14.x/api/events.html
[7]: https://blog.cloudboost.io/waiting-for-db-connections-before-app-listen-in-node-f568af8b9ec9
[8]: https://archive.today/mO5iz
