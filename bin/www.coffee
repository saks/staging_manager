# unless process.env.COOKIE_SECRET
#   process.env.COOKIE_SECRET = 'bC7BEZ5MVzfZmjgeSufcZwP5RcZyUWrWazKIkoovyT6J56sM0l0QvZQvOhtJs9X4'

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

passportStub = {
  _userProperty:   'user'
  _key:            'passport'
  deserializeUser: (user, callback) ->
    User.current user.id, (err, currentUser) ->
      callback err, currentUser
}

io.use(passportSocketIo.authorize({
  passport:     passportStub,
  cookieParser: cookieParser,
  key:         EXPRESS_SID_KEY,       # the name of the cookie where express/connect stores its session_id
  secret:      process.env.SESSION_SECRET,    # the session_secret to parse the cookie
  store:       sessionStore,        # we NEED to use a sessionstore. no memorystore please
  success:     onAuthorizeSuccess,  # *optional* callback on success - read more below
  fail:        onAuthorizeFail,     # *optional* callback on fail/error - read more below
}))


io.on('connection', (socket) ->
  request     = socket.conn.request
  currentUser = request[passportStub._userProperty]
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
