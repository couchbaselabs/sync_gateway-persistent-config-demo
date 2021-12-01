# What's new in Sync Gateway Configuration & Administration
## A Couchbase Connect 2021 presentation

[![What's New in Sync Gateway Configuration and Administration - CBConnect21](.ytthumb.gif)](https://www.youtube.com/watch?v=N7EG9t68_2s)

## Setup

### Couchbase Server
1. `docker-compose up --detach db` will start Couchbase Server
2. `./setup-db.sh` will configure Couchbase Server with credentials `Administrator` `password`, and initialise some buckets.

### Sync Gateway
1. `docker-compose up --detach` will start 3 Couchbase Sync Gateway nodes, and a load balancer
2. `docker-compose logs --follow` to see logs
3. Create the `beers` Database on the `beer-sample` bucket against a random SG node.
`curl -X PUT http://Administrator:password@localhost:4985/beers/ -H 'Content-Type: application/json' -d '{"bucket":"beer-sample","num_index_replicas": 0,"import_docs":false}'`
4. `docker-compose up --detach --scale sg=10` will start 7 more Sync Gateway nodes, for a total of 10. All picking up the beers database automatically on startup.
5. Tweak a single database config option on a single node, and watch it propagate to all other nodes in the Sync Gateway cluster.
`curl -X POST http://Administrator:password@localhost:4985/beers/_config -H 'Content-Type: application/json' -d '{"cache":{"rev_cache":{"size":31337}}}'`

### Import
1. `docker-compose up --detach --scale sg=10 --scale=sg-import=1` will start an import Sync Gateway node in a separate group ID.
2. Again, create the `beers` database for the import group. **Note the import-specific port number...**
`curl -X PUT http://Administrator:password@localhost:14985/beers/ -H 'Content-Type: application/json' -d '{"bucket":"beer-sample","num_index_replicas":0,"import_docs":true}'`
3. `docker-compose logs --follow` to see logs and observe the import node working, separate from the 10 client-facing nodes above.
4. Tweak import config group independently, without affecting other groups. Here we're turning down the cache sizes for our import node. **Again, note the port number...**
`curl -X POST http://Administrator:password@localhost:14985/beers/_config -H 'Content-Type: application/json' -d '{"cache":{"rev_cache":{"size":0},"channel_cache":{"max_number":100,"enable_star_channel":false,"max_length":1,"min_length":1}}}'`

### Legacy Config Upgrade
1. `docker-compose up --detach --scale sg=0 --scale sg-import=0 --scale sg-legacy=1` will automatically upgrade the legacy Sync Gateway config inside `sg-legacy-config` and start up a single node.
