mongoose = require 'mongoose'
Schema   = mongoose.Schema

ServerSchema = new Schema
  name:           String
  ip_address:     String
  locked:         Boolean
  locked_by_id:   Number
  locked_by_name: String


ServerSchema.options.toJSON = {
  transform: (doc, ret, options) ->
    ret.id = ret._id
    delete ret._id
    delete ret.__v
    ret
}

mongoose.model 'Server', ServerSchema
