express  = require 'express'
router   = express.Router()
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

# GET home page.
router.get '/', (req, res) ->
  Server.find (err, servers) ->
    result =
      servers: []
      foo: 3

    servers.forEach (server) ->
      result.servers.push
        id: server.id
        name: server.name
        ip_address: server.ip_address

      return

    res.json result
    return

  return

module.exports = router
