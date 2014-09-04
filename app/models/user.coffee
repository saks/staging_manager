mongoose = require 'mongoose'
request  = require 'request'
Schema   = mongoose.Schema

UserSchema = new Schema({
  login:               String,
  github_user_id:      Number,
  avatar_url:          String,
  gravatar_id:         String,
  url:                 String,
  html_url:            String,
  followers_url:       String,
  following_url:       String,
  gists_url:           String,
  starred_url:         String,
  subscriptions_url:   String,
  organizations_url:   String,
  repos_url:           String,
  events_url:          String,
  received_events_url: String,
  type:                String,
  site_admin:          Boolean,
  name:                String,
  company:             String,
  blog:                String,
  location:            String,
  email:               String,
  hireable:            Boolean,
  bio:                 String,
  public_repos:        Number,
  public_gists:        Number,
  followers:           Number,
  following:           Number,
  created_at:          String,
  updated_at:          String,
})

UserSchema.options.toJSON = {
  transform: (doc, ret, options) ->
    ret.id = ret._id
    delete ret._id
    delete ret.__v
    ret
}

## static methods
UserSchema.methods.verboseName = ->
  @name || @email || @login


# find-and-return or create-and-return user by github login attribute
UserSchema.statics.userByGithubLogin = (githubLogin, returnCallback) ->
  @findOne login: githubLogin, (findError, user) ->
    if findError or not user
      mongoose.model('User').createByGithubLogin githubLogin, returnCallback
    else
      returnCallback findError, user


# get data from github and save to db as user model
UserSchema.statics.createByGithubLogin = (githubLogin, returnCallback) ->
  options =
    url:      "https://api.github.com/users/#{githubLogin}",
    headers:  'User-Agent': 'request'

  callback = (error, response, body) ->
    if error
      return returnCallback error

    userData                = JSON.parse body
    userData.github_user_id = userData.id
    delete userData.id

    mongoose.model('User').findOneAndUpdate github_user_id: userData.github_user_id,
      userData, upsert: true, returnCallback

  request options, callback


UserSchema.statics.current = (id, callback) ->
  if id
    @findById id, callback
  else
    callback()


mongoose.model 'User', UserSchema
