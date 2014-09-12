unless process.env.SESSION_SECRET
  process.env.SESSION_SECRET = 'P9O9QyedWcUAmwRr6HkkS5DZvmqFGoLRrm17UsIavkXwurskrJIbbUDQnrgkSar2'

EXPRESS_SID_KEY = 'express.session'

signature = require('cookie-signature')
debug = require('debug')('staging_manager')
app   = require('../app')

app.set 'port', process.env.PORT or 3000
server = app.listen(app.get('port'), ->
  debug 'Express server listening on port ' + server.address().port
  return
)
passport = require 'passport'
io = require('socket.io').listen(server)
mongoose = require 'mongoose'
User = mongoose.model 'User'
Server = mongoose.model 'Server'

sessionStore = app.locals.sessionStore
cookieParser = require('cookie-parser')

passportSocketIo = require("passport.socketio")

onAuthorizeSuccess = (data, accept) ->
  console.log 'auth success'
  accept()

onAuthorizeFail = (data, message, error, accept) ->
  console.log message, error
  console.log 'auth fail'

io.use(passportSocketIo.authorize({
  passport:     passport,
  cookieParser: cookieParser,
  key:         EXPRESS_SID_KEY,       # the name of the cookie where express/connect stores its session_id
  secret:      process.env.SESSION_SECRET,    # the session_secret to parse the cookie
  store:       sessionStore,        # we NEED to use a sessionstore. no memorystore please
  success:     onAuthorizeSuccess,  # *optional* callback on success - read more below
  fail:        onAuthorizeFail,     # *optional* callback on fail/error - read more below
}))

class SocketRegistry
  constructor: ->
    @registry = {}

  push: (userId, socket) ->
    unless @registry[userId]
      @registry[userId] = []

    @registry[userId].push socket

  pop: (userId) ->
    if @registry[userId]
      @registry[userId].forEach (socket) ->
        console.log "disconnect user #{socket.conn.request.user.verboseName()}"
        socket.disconnect()

socketRegistry = app.locals.socketRegistry = new SocketRegistry

io.on('connection', (socket) ->
  request     = socket.conn.request
  currentUser = request.user
  socketRegistry.push currentUser.id, socket
  console.log "connected user #{currentUser.verboseName()}"

  socket.on '/servers/lock', (data) ->
    console.log "lock server #{data}"
    Server.lock data.id, currentUser, (error, server) ->
      if error
        # TODO: socket.emit 'news', server: server
      else
        socket.emit 'servers/update', server: server
        socket.broadcast.emit 'servers/update', server: server

  socket.on '/servers/unlock', (data) ->
    console.log "unlock server #{data}"
    Server.unlock data.id, currentUser, (error, server) ->
      if error
        # TODO: socket.emit 'news', server: server
      else
        socket.emit 'servers/update', server: server
        socket.broadcast.emit 'servers/update', server: server

  # sender = setInterval(->
  #   socket.emit('myCustomEvent', new Date().getTime())
  # , 1000)
  #
  # socket.on('disconnect', ->
  #   clearInterval(sender)
  # )
)
