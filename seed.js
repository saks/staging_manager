// mongo staging_manager_development seed.js

db.dropDatabase();

[
  { name: 'staging 1', host: 'staging1.xvtest.net', locked: false, ip_address: '1.116.11.135' },
  { name: 'staging 2', host: 'staging2.xvtest.net', locked: false, ip_address: '13.255.247.185' },
  { name: 'staging 3', host: 'staging3.xvtest.net', locked: false, ip_address: '1.92.24.145' },
  { name: 'staging 4', host: 'staging4.xvtest.net', locked: false, ip_address: '1.92.24.146' },
].forEach(function(server) { db.servers.save(server) })

