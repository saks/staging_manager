path = require 'path'
GLOBAL.APP_ROOT = path.join __dirname, '/..'

GLOBAL.expect  = require 'expect.js'
GLOBAL.Factory = require 'factory-lady'

require "#{APP_ROOT}/test/factories"
