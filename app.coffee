require './db'
require './app/models/server'
require './app/models/user'
express      = require('express')
logfmt       = require('logfmt')
path         = require('path')
favicon      = require('static-favicon')
logger       = require('morgan')
cookieParser = require('cookie-parser')
bodyParser   = require('body-parser')
routes       = require('./routes/index')
users        = require('./routes/users')
servers      = require('./routes/servers')
session      = require('express-session')
cookieParser = require('cookie-parser')
redis        = require('redis')
redisClient  = redis.createClient()
RedisStore   = require('connect-redis')(session)
sessionStore = new RedisStore client: redisClient, host: 'localhost', port: '6379'
app          = express()


# view engine setup
app.set 'views', path.join(__dirname, 'app', 'views')
app.set 'view engine', 'jade'

app.use favicon()
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser('bC7BEZ5MVzfZmjgeSufcZwP5RcZyUWrWazKIkoovyT6J56sM0l0QvZQvOhtJs9X4')
app.use session(
  key:    'app.session'
  secret: 'P9O9QyedWcUAmwRr6HkkS5DZvmqFGoLRrm17UsIavkXwurskrJIbbUDQnrgkSar2'
  store:   sessionStore
)
app.use express.static(path.join(__dirname, 'public'))

app.use '/',        routes
app.use '/users',   users
app.use '/servers', servers

#/ catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next err
  return


#/ error handlers

# development error handler
# will print stacktrace
if app.get('env') is 'development'
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render 'error',
      message: err.message
      error: err

    return


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  app.use logfmt.requestLogger()
  res.status err.status or 500
  res.render 'error',
    message: err.message
    error: {}

  return

module.exports = app
