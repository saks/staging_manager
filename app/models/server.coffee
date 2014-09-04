mongoose = require 'mongoose'
Schema   = mongoose.Schema

ServerSchema = new Schema
  name:           String
  host:           String
  ip_address:     String
  locked:         Boolean
  locked_by_id:   Schema.Types.ObjectId
  locked_by_name: String
  locked_at:      Date
  branch:         String
  revision:       String
  deployed_at:    Date
  deployed_by_id: Schema.Types.ObjectId
  deployed_by_name:  String
  deployed_by_login: String


ServerSchema.options.toJSON = {
  transform: (doc, ret, options) ->
    ret.id = ret._id
    delete ret._id
    delete ret.__v
    ret
}

# options: { id: <server model id>, locked: <boolean>, user: <current user> }
ServerSchema.statics.toggleLock = (options, callback) ->
  @findById options.id, (findError, server) ->
    if findError
      callback findError, server
      return

    server.locked = options.locked

    server.save (saveError, updatedServer, numberAffected) ->
      wasUpdated = 1 is numberAffected

      if (not wasUpdated) or saveError
        callback saveError, updatedServer
        return

      if server.locked
        server.locked_by_id   = options.user.id
        server.locked_by_name = options.user.verboseName()
        server.locked_at      = new Date()
      else
        server.locked_by_id = server.locked_by_name = server.locked_at = undefined

      server.save (saveError, updatedServer, numberAffected) ->
        callback saveError, updatedServer

ServerSchema.statics.recordDeployment = (params, returnCallback) ->
  @findOne host: params.host, (findError, server) ->
    return returnCallback findError if findError
    return returnCallback new Error "Cannot find server by host: `#{params.host}'" unless server

    server.branch           = params.branch
    server.revision         = params.revision
    server.deployed_at      = Date Date.parse params.deployed_at

    mongoose.model('User').userByGithubLogin params.deployed_by_name, (error, user) ->
      return returnCallback error if error

      server.deployed_by_name  = user.verboseName()
      server.deployed_by_login = user.login
      server.deployed_by_id    = user.id

      server.save returnCallback

mongoose.model 'Server', ServerSchema
