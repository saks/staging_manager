// mongo staging_manager_development seed.js

db.dropDatabase();

[
  { name: 'staging 1', host: 'my.host.name', locked: false, ip_address: '8.8.8.8' },
].forEach(function(server) { db.servers.save(server) })

