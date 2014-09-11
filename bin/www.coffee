unless process.env.COOKIE_SECRET
  process.env.COOKIE_SECRET = 'bC7BEZ5MVzfZmjgeSufcZwP5RcZyUWrWazKIkoovyT6J56sM0l0QvZQvOhtJs9X4'

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
User = require('mongoose').model 'User'

sessionStore = app.locals.sessionStore
cookieParser = app.locals.cookieParser

io.set('authorization', (data, callback) ->
  if not data.headers.cookie
    console.log 'No cookie transmitted.'
    return callback('No cookie transmitted.', false)

  # We use the Express cookieParser created before to parse the cookie
  # Express cookieParser(req, res, next) is used initialy to parse data in "req.headers.cookie".
  # Here our cookies are stored in "data.headers.cookie", so we just pass "data" to the first argument of function
  cookieParser(data, {}, (parseErr) ->
    if parseErr
      console.log 'Error parsing cookies.'
      return callback('Error parsing cookies.', false)

    # Get the SID cookie
    sidCookie = (data.secureCookies && data.secureCookies[EXPRESS_SID_KEY]) or
      (data.signedCookies && data.signedCookies[EXPRESS_SID_KEY]) or
      (data.cookies && data.cookies[EXPRESS_SID_KEY])

    sidCookie = signature.unsign(sidCookie.slice(2), process.env.SESSION_SECRET)

    # Then we just need to load the session from the Express Session Store
    sessionStore.load(sidCookie, (err, session) ->
      # And last, we check if the used has a valid session and if he is logged in
      if (err or not session or not session.user_id)
        console.log 'Not logged in.'
        callback('Not logged in.', false)
      else
        # If you want, you can attach the session to the handshake data, so you can use it again later
        # You can access it later with "socket.handshake.session"

        User.current session.user_id, (err, currentUser) ->
          if not err and currentUser
            data.session = session
            data.currentUser = currentUser
            callback null, true
          else
            console.log 'Not logged in.'
            callback('Not logged in.', false)
    )
  )
)


io.on('connection', (socket) ->
  console.log 'connected'
  # sender = setInterval(->
  #   socket.emit('myCustomEvent', new Date().getTime())
  # , 1000)
  #
  # socket.on('disconnect', ->
  #   clearInterval(sender)
  # )
)
