mongoose = require 'mongoose'
Schema   = mongoose.Schema

ServerSchema = new Schema({
  name:       String,
  ip_address: String,
})

ServerSchema.statics.allAsJson = (callback) ->
  result = { servers: [] }

  @find (err, servers) ->
    servers.forEach (server) ->
      result.servers.push
        id:         server.id
        name:       server.name
        ip_address: server.ip_address

    callback result

mongoose.model 'Server', ServerSchema
