mongoose = require 'mongoose'
Schema   = mongoose.Schema

ServerSchema = new Schema
  name:           String
  ip_address:     String
  locked:         Boolean
  locked_by_id:   Number
  locked_by_name: String


ServerSchema.options.toJSON = {
  transform: (doc, ret, options) ->
    ret.id = ret._id
    delete ret._id
    delete ret.__v
    ret
}

ServerSchema.statics.toggleLock = (id, serverAttributes, callback) ->
  @findById id, (findError, server) ->
    if findError
      callback findError, server
      return

    server.locked = serverAttributes.locked

    server.save (saveError, updatedServer, numberAffected) ->
      wasUpdated = 1 is numberAffected

      if (not wasUpdated) or saveError
        callback saveError, updatedServer
        return

      server.locked_by_id   = serverAttributes.locked_by_id
      server.locked_by_name = serverAttributes.locked_by_name

      server.save (saveError, updatedServer, numberAffected) ->
        callback saveError, updatedServer

mongoose.model 'Server', ServerSchema
