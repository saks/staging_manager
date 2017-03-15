unless process.env.SESSION_SECRET
  process.env.SESSION_SECRET = 'P9O9QyedWcUAmwRr6HkkS5DZvmqFGoLRrm17UsIavkXwurskrJIbbUDQnrgkSar2'

EXPRESS_SID_KEY = 'express.session'
ALLOWED_USER_IDS = [
  99110,   # saksmlz
  # 8592060, # test account
]

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
app.set 'io', io

mongoose = require 'mongoose'
User = mongoose.model 'User'
Server = mongoose.model 'Server'

sessionStore = app.locals.sessionStore
cookieParser = require('cookie-parser')

passportSocketIo = require 'passport.socketio'

onAuthorizeSuccess = (data, accept) ->
  return false if ALLOWED_USER_IDS.indexOf(data.user.github_user_id) < 0

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

  Server.find().sort('name').exec (err, document) ->
    socket.emit '/servers/index', servers: document


  # try to unlock server by it's id
  socket.on '/servers/lock', (data) ->
    Server.lock data.id, currentUser, (error, server) ->
      if error
        socket.emit '/error'
      else
        socket.emit '/servers/update', server: server
        socket.broadcast.emit '/servers/update', server: server


  # try to lock server by it's id
  socket.on '/servers/unlock', (data) ->
    Server.unlock data.id, currentUser, (error, server) ->
      if error
        socket.emit '/error'
      else
        socket.emit '/servers/update', server: server
        socket.broadcast.emit '/servers/update', server: server
)
