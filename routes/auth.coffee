express = require 'express'
router  = express.Router()
mongoose = require 'mongoose'
User     = mongoose.model 'User'
passport = require 'passport'
GitHubStrategy = require('passport-github').Strategy

REDIRECT_URL = if 'development' is process.env.NODE_ENV
  'http://localhost:3000/auth/callback'
else
  'http://staging-manager.herokuapp.com/auth/callback'

passport.use(new GitHubStrategy({
    clientID:     process.env.OAUTH_CLIENT_ID or 'a4e05cf138141b4aa798'
    clientSecret: process.env.OAUTH_CLIENT_SECRET or '65a0be079a33212f44dfc86d54a26322e769b8d8'
    callbackURL:  REDIRECT_URL
  },
  (accessToken, refreshToken, profile, done) ->
    profile._json.github_user_id = profile.id
    delete profile._json.id

    User.findOneAndUpdate({github_user_id: profile.id}, profile._json, { upsert: true }, (err, user) ->
      done err, user
    )
))


passport.serializeUser((user, done) ->
  done(null, user.id)
)

passport.deserializeUser((id, done) ->
  User.findById id, (err, user) ->
    done(err, user)
)


# Initial page redirecting to Github
router.get '/signin', passport.authenticate('github')

router.get '/signout', (req, res) ->
  req.logout()
  res.redirect '/'

# Callback service parsing the authorization token and asking for the access token
router.get '/callback', passport.authenticate('github', failureRedirect: '/auth/signin'), (req, res) ->
  res.redirect('/')


module.exports = router
