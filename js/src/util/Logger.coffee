define 'kryptnostic.logger', [
  'require'
  'lodash'
  'loglevel'
], (require) ->

  log = require 'loglevel'
  _   = require 'lodash'

  # log configuration
  # =================

  PERSIST = true

  log.setLevel('trace', PERSIST)

  # helpers
  # =======

  format = (message, args) ->
    if _.isArray(args) && args.length
      return "#{message} #{args.map(JSON.stringify)}"
    else
      return message

  #
  # Proxy logger which appends module names before logging.
  # Author: rbuckheit
  #
  class Logger

    @get : (moduleName) ->
      return new Logger(moduleName)

    constructor : (@moduleName) ->

    @setLevel: (level) ->
      log.info('log level changing to', level)
      log.setLevel(level, PERSIST)

    trace : (message, args...) ->
      log.trace("[#{@moduleName}] #{format(message, args)}")

    info : (message, args...) ->
      log.info("[#{@moduleName}] #{format(message, args)}")

    warn : (message, args...) ->
      log.warn("[#{@moduleName}] #{format(message, args)}")

    error : (message, args...) ->
      log.error("[#{@moduleName}] #{format(message, args)}")

    debug: (message, args...) ->
      log.debug("[#{@moduleName}] #{format(message, args)}")

  return Logger
