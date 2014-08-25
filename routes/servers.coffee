express  = require 'express'
router   = express.Router()
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

# GET servers list as json
router.get '/', (request, response) ->
  Server.find (err, document) ->
    response.json servers: document unless err

# PUT update server model. Currently can only lock or unlock server.
router.put '/:id', (request, response) ->
  Server.findById request.params.id, (findError, server) ->
    if not findError
      server.locked = request.body.server.locked

      server.save (saveError, updatedServer, numberAffected) ->
        response.status(406) unless 1 is numberAffected

        if not saveError
          response.json { server: updatedServer }
        else
          response.status(406).json error: saveError

module.exports = router
