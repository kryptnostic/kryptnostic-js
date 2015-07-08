define 'soteria.logger', [
  'require'
  'loglevel'
], (require) ->

  # log configuration
  # =================

  log     = require 'loglevel'
  PERSIST = true
  log.setLevel('trace', PERSIST)

  #
  # Proxy logger which appends module names before logging.
  # Author: rbuckheit
  #
  class Logger

    @get : (moduleName) ->
      return new Logger(moduleName)

    constructor : (@moduleName) ->

    trace : (message, args...) ->
      args = args.map(JSON.stringify)
      log.trace("[#{@moduleName}] #{message} #{args}")

    info : (message, args...) ->
      args = args.map(JSON.stringify)
      log.info("[#{@moduleName}] #{message} #{args}")

    warn : (message, args...) ->
      args = args.map(JSON.stringify)
      log.warn("[#{@moduleName}] #{message} #{args}")

    error : (message, args...) ->
      args = args.map(JSON.stringify)
      log.error("[#{@moduleName}] #{message} #{args}")

    debug: (message, args...) ->
      args = args.map(JSON.stringify)
      log.debug("[#{@moduleName}] #{message} #{args}")

  return Logger
