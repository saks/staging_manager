url      = require 'url'
request  = require 'request'
mongoose = require 'mongoose'
User     = mongoose.model 'User'

OAuth2 = require('simple-oauth2')({
  clientID: '172930e2f1537d803337',
  clientSecret: '8323940a33c2aff4c0461eeb594854f9af9b482d',
  site: 'https://github.com/login',
  tokenPath: '/oauth/access_token'
})

# Authorization uri definition

class SMAuth
  @ALLOWED_USER_IDS = [
    99110,   # saksmlz
    383206,  # peter
    729524,  # jess
    648293,  # matt
    5697447, # weining
  ]
  @authorization_uri = OAuth2.AuthCode.authorizeURL({
    redirect_uri: 'http://localhost:3000/callback',
    scope: 'user:email',
    state: '3(#0/!~'
  })

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
      redirect_uri: 'http://localhost:3000/callback'
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
