express = require('express')
router  = express.Router()
url     = require 'url'

# GET home page.
router.get '/', (request, response) ->
  response.render 'index', title: 'Express'

# GET heartbeat
router.get '/heartbeat', (request, response) ->
  response.json 200, 'OK'

OAuth2 = require('simple-oauth2')({
  clientID: '172930e2f1537d803337',
  clientSecret: '8323940a33c2aff4c0461eeb594854f9af9b482d',
  site: 'https://github.com/login',
  tokenPath: '/oauth/access_token'
})

# Authorization uri definition
authorization_uri = OAuth2.AuthCode.authorizeURL({
  redirect_uri: 'http://localhost:3000/callback',
  scope: 'user:email',
  state: '3(#0/!~'
})

# Initial page redirecting to Github
router.get '/auth', (req, res) ->
  res.redirect(authorization_uri)

# Callback service parsing the authorization token and asking for the access token
router.get '/callback', (req, res) ->
  code = req.query.code

  saveToken = (error, result) ->
    console.log('Access Token Error', error.message) if error

    tokenObject  = OAuth2.AccessToken.create(result)
    access_token = url.parse("http://foo/?#{tokenObject.token}", true).query.access_token

    res.json token: access_token
    # res.render 'index',

  OAuth2.AuthCode.getToken({
    code: code,
    redirect_uri: 'http://localhost:3000/callback'
  }, saveToken)



module.exports = router
