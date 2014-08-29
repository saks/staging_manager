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

# PUT update server model. Currently can only toggle lock.
router.put '/:id', (request, response) ->
  response.status 403 unless request.session.user_id
  serverAttributes = request.body.server

  Server.toggleLock request.params.id, serverAttributes, (error, server) ->
    if error
      response.status(406).json error: error
    else
      response.json { server: server }

module.exports = router
