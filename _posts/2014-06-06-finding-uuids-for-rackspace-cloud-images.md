---
layout: post
title:  Locating UUIDs for Rackspace Cloud Images
day:    2
---

This isn't as simple as you would think and requires a 2 step process.  Using curl seems like the most obvious tool here.  It's probably not the best, but we'll use it anyway:

1. Authenticate with your username and API key to receive an API token

```
curl -s https://identity.api.rackspacecloud.com/v2.0/tokens \
  -d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"<username>", "apiKey":"<api-key>"}}}' \
  -H "Content-Type: application/json"
```

This will return a large JSON payload -- look for the 'token' key and copy the values from the 'token/id' and 'token/tenent/id' fields.

2. Use your "tenent ID" along with your API token to retrieve a list of available images

```
curl \
  -s https://dfw.servers.api.rackspacecloud.com/v2/<tenent-id>/images/detail \
  -H "X-Auth-Token: 73ec5794bae8449fa3056e10f8b40daf" > images.json
```

This will return a large JSON document, but just look for the name of the image you're interested in -- you'll want the corresponding value from the `id` field.
