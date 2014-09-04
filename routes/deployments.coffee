express  = require 'express'
router   = express.Router()

auth     = require 'basic-auth'
bufferEq = require 'buffer-equal-constant-time'

mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

# Authenticator
isAuthenticated = (request, response, next) ->
  unless process.env.NODE_ENV is 'production'
    next()
    return

  user = auth request
  name = new Buffer user.name
  pass = new Buffer user.pass

  correntName = new Buffer process.env.API_AUTH_NAME
  correntPass = new Buffer process.env.API_AUTH_PASS

  if bufferEq(name, correntName) and bufferEq(pass, correntPass)
    next()
  else
    response.status(401).send 'fail'

router.use isAuthenticated




# POST create deployment
# request params:
# - host
# - branch
# - revision
# - deployed_at
# - deployed_by_name
router.post '/', (request, response) ->
  Server.recordDeployment request.body, (error) ->
    if error
      response.status(406).send error.message
    else
      response.send 'OK'

module.exports = router
