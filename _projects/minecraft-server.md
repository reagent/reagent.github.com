---
name: minecraft-server
language: Ansible / Python
featured: true
priority: 80
repository_url: https://github.com/reagent/minecraft-server
---

After experiencing lag on our outdated home computers when using "Open to LAN",
I took some time to pull together an existing Ansible role to create an
on-demand Minecraft server on Digital Ocean. I experimented a bit with using
[Block Storage][1] to store world data, but moved to persisting data in a
[Space][2] to allow for a multi-server setup.

[1]: https://www.digitalocean.com/products/block-storage/
[2]: https://www.digitalocean.com/products/spaces/
