url      = require 'url'
request  = require 'request'
mongoose = require 'mongoose'
User     = mongoose.model 'User'

OAuth2 = require('simple-oauth2')({
  clientID:     process.env.OAUTH_CLIENT_ID or 'a4e05cf138141b4aa798'
  clientSecret: process.env.OAUTH_CLIENT_SECRET or '65a0be079a33212f44dfc86d54a26322e769b8d8'
  site:         'https://github.com/login'
  tokenPath:    '/oauth/access_token'
})

REDIRECT_URL = if 'development' is process.env.NODE_ENV
  'http://localhost:3000/auth/callback'
else
  'http://staging-manager.herokuapp.com/auth/callback'

# Authorization uri definition

class SMAuth
  @ALLOWED_USER_IDS = [
    99110,   # saksmlz
    383206,  # peter
    729524,  # jess
    648293,  # matt
    5697447, # weining
    8592060, # test account
  ]
  @authorization_uri = OAuth2.AuthCode.authorizeURL({
    redirect_uri: REDIRECT_URL,
    scope: 'user:email',
    state: '3(#0/!~'
  })

  # TODO: handle errors better
  constructor: (code, resultCallback) ->
    authObject = this

    saveToken = (error, result) ->
      console.log('Access Token Error', error.message) if error

      tokenObject  = OAuth2.AccessToken.create(result)
      access_token = url.parse("http://foo/?#{tokenObject.token}", true).query.access_token

      authObject.getUserData access_token, (err, user) ->
        resultCallback err, user

    OAuth2.AuthCode.getToken({
      code: code,
      redirect_uri: REDIRECT_URL
    }, saveToken)


  getUserData: (token, resultCallback) ->
    console.log "try to get info with token: #{token}"
    authObject = this

    options = {
      url: 'https://api.github.com/user',
      headers: {
        'Authorization': "token #{token}",
        'User-Agent':    'request'
      }
    }

    callback = (error, response, body) ->
      if not error and response.statusCode is 200
        userData = JSON.parse(body)
        userData.github_user_id = userData.id

        if authObject.isUserAllowed userData.github_user_id
          delete userData.id

          User.findOneAndUpdate({github_user_id: userData.github_user_id}, userData, { upsert: true }, (err, doc) ->
            resultCallback err, doc
          )
        else
          error = 'You are not allowed to sign in'
          console.log error
          resultCallback error


      else
        resultCallback error

    request options, callback

  isUserAllowed: (userId) ->
    SMAuth.ALLOWED_USER_IDS.indexOf(userId) >= 0

module.exports = SMAuth
