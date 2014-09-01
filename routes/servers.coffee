express  = require 'express'
router   = express.Router()
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'
User     = mongoose.model 'User'

isAuthenticated = (request, response, next) ->
  session = request.session
  response.redirect '/' unless session and session.user_id

  User.current session, (err, currentUser) ->
    if not err and currentUser
      response.locals.currentUser = currentUser
      return next()
    else
      response.redirect '/'


router.use isAuthenticated

# GET servers list as json
router.get '/', (request, response) ->
  Server.find().sort('name').exec (err, document) ->
    response.json servers: document unless err

# PUT update server model. Currently can only toggle lock.
router.put '/:id', (request, response) ->
  options =
    id: request.params.id,
    locked: request.body.server.locked,
    user: response.locals.currentUser

  Server.toggleLock options, (error, server) ->
    if error
      response.status(406).json error: error
    else
      response.json { server: server }

module.exports = router
