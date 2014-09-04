mongoose = require 'mongoose'
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

UserSchema.methods.verboseName = ->
  @name || @email || @login

UserSchema.statics.current = (id, callback) ->
  if id
    @findById id, callback
  else
    callback()

mongoose.model 'User', UserSchema
