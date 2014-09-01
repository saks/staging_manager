express  = require 'express'
router   = express.Router()
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'
User     = mongoose.model 'User'

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


  User.current request.session, (err, currentUser) ->
    options = {
      id:     request.params.id,
      locked: request.body.server.locked
      user:   currentUser
    }

    Server.toggleLock options, (error, server) ->
      if error
        response.status(406).json error: error
      else
        response.json { server: server }

module.exports = router
