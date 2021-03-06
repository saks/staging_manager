path = require 'path'
GLOBAL.APP_ROOT = path.join __dirname, '/..'

chai          = require 'chai'
GLOBAL.expect = chai.expect
chai.use require 'chai-datetime'
chai.use require 'chai-change'

GLOBAL.Factory = require 'factory-lady'

require "#{APP_ROOT}/test/factories"
