require './db'
require './app/models/server'
require './app/models/user'

# libs
express      = require 'express'
logfmt       = require 'logfmt'
path         = require 'path'
favicon      = require 'static-favicon'
logger       = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser   = require 'body-parser'
session      = require 'express-session'
compression  = require 'compression'
cookieParser = require 'cookie-parser'
redis        = require 'redis'
RedisStore   = require('connect-redis')(session)
url          = require 'url'

# routes
routes       = require './routes/index'
users        = require './routes/users'
servers      = require './routes/servers'
authRoutes   = require './routes/auth'
apiRoutes    = require './routes/api'

newrelic = if process.env.NEW_RELIC_LICENSE_KEY
  require 'newrelic'
else
  { getBrowserTimingHeader: -> }

# connect to redis
if process.env.REDISTOGO_URL
  redisURL    = url.parse process.env.REDISTOGO_URL
  password    = redisURL.auth.split(":")[1]
  redisClient = redis.createClient redisURL.port, redisURL.hostname
  redisClient.auth password
else
  redisClient = redis.createClient()


sessionStore = new RedisStore client: redisClient

# view engine setup
app = express()
app.locals.newrelic = newrelic
app.set 'views', path.join(__dirname, 'app', 'views')
app.set 'view engine', 'jade'

# middlewares
app.use compression threshold: false
app.use require('connect-assets')()
app.use favicon()
app.use logger('dev') if app.get('env') isnt 'test'
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
app.use '/auth',    authRoutes
app.use '/api',     apiRoutes
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
  if app.get('env') isnt 'test'
    app.use logfmt.requestLogger()
  res.status err.status or 500
  res.render 'error',
    message: err.message
    error: {}

  return

module.exports = app
