express = require('express')
router  = express.Router()
mongoose = require 'mongoose'
User    = mongoose.model 'User'
SMAuth  = require './../lib/smauth'


# GET home page.
router.get '/', (request, response) ->
  session = request.session

  User.current session, (err, currentUser) ->
    response.render 'index', title: 'Express', currentUser: currentUser

# GET heartbeat
router.get '/heartbeat', (request, response) ->
  response.json 200, 'OK'

# Initial page redirecting to Github
router.get '/auth', (req, res) ->
  session = req.session
  if session.user_id
    res.redirect '/'
  else
    res.redirect SMAuth.authorization_uri

# Callback service parsing the authorization token and asking for the access token
router.get '/callback', (req, res) ->
  session = req.session
  code = req.query.code

  new SMAuth code, (error, user) ->
    session.user_id = user.id unless error
    res.redirect '/'

router.get '/logout', (req, res) ->
  delete req.session.user_id
  res.redirect '/'


module.exports = router
