// mongo staging_manager seed.js

db.dropDatabase();

[
  { name: 'staging 1', locked: false, ip_address: '50.116.11.135' },
  { name: 'staging 2', locked: false, ip_address: '173.255.247.185' },
  { name: 'staging 3', locked: false, ip_address: '23.92.24.145' },
].forEach(function(server) { db.servers.save(server) })

