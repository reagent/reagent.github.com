---
name: minecraft-server
language: Ansible / Python
featured: true
priority: 8
repository_url: https://github.com/reagent/minecraft-server
---

After experiencing lag on our outdated home computers when using
"Open to LAN", I took some time to pull together an existing Ansible role to
create an on-demand Minecraft server on Digital Ocean.  I experimented a bit
with using [Block Storage](https://www.digitalocean.com/products/block-storage/)
to store world data, but moved to persisting data in a
[Space](https://www.digitalocean.com/products/spaces/) to allow for a
multi-server setup.
