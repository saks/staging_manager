express  = require 'express'
router   = express.Router()
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'
User     = mongoose.model 'User'

isAuthenticated = (request, response, next) ->
  if 'test' == process.env.NODE_ENV
    return User.findOne (err, user) ->
      response.locals.currentUser = user
      return next()


  session = request.session

  unless session.user_id
    response.redirect '/'
    return

  User.current session.user_id, (err, currentUser) ->
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

# GET server by id
router.get '/:id', (request, response) ->
  Server.findById request.params.id, (findError, server) ->
    if findError
      response.status(404).json error: findError
    else
      response.json server: server

# PUT update server model. Currently can only toggle lock.
router.put '/:id', (request, response) ->
  server = request.body.server or {}

  options =
    id:     request.params.id
    locked: server.locked
    user:   response.locals.currentUser

  Server.toggleLock options, (error, server) ->
    if error
      response.status(406).json error: error
    else
      response.json { server: server }

module.exports = router
