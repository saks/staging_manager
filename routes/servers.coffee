express  = require 'express'
router   = express.Router()
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

# GET servers list as json
router.get '/', (request, response) ->
  unless request.session.user_id
    response.json servers: []
    return

  Server.find().sort('name').exec (err, document) ->
    response.json servers: document unless err

# PUT update server model. Currently can only lock or unlock server.
router.put '/:id', (request, response) ->
  response.status 403 unless request.session.user_id

  Server.findById request.params.id, (findError, server) ->
    if not findError
      serverAttributes = request.body.server

      server.locked          = serverAttributes.locked
      server.locked_by_id    = serverAttributes.locked_by_id
      server.locked_by_email = serverAttributes.locked_by_email

      server.save (saveError, updatedServer, numberAffected) ->
        response.status(406) unless 1 is numberAffected

        if not saveError
          response.json { server: updatedServer }
        else
          response.status(406).json error: saveError

module.exports = router
