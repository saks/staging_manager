var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var Server     = mongoose.model('Server');

/* GET home page. */
router.get('/', function(req, res) {
  Server.find(function(err, servers) {
    result = { servers: [] };
    servers.forEach(function(server) {
      result.servers.push({ id: server.id, name: server.name, ip_address: server.ip_address })
    })
    res.json(result);
  });
});

module.exports = router;
