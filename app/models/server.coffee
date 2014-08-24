mongoose = require 'mongoose'
Schema   = mongoose.Schema

ServerSchema = new Schema({
  name:       String,
  ip_address: String,
  locked:     Boolean,
})

ServerSchema.options.toJSON = {
  transform: (doc, ret, options) ->
    ret.id = ret._id
    delete ret._id
    delete ret.__v
    ret
}

mongoose.model 'Server', ServerSchema
