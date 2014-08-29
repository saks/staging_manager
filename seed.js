// mongo staging_manager_development seed.js

db.dropDatabase();

[
  { name: 'staging 1', locked: false, ip_address: '1.116.11.135' },
  { name: 'staging 2', locked: false, ip_address: '13.255.247.185' },
  { name: 'staging 3', locked: false, ip_address: '1.92.24.145' },
  { name: 'staging 4', locked: false, ip_address: '1.92.24.146' },
].forEach(function(server) { db.servers.save(server) })

