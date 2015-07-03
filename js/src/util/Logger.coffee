define 'soteria.logger', [], (require) ->

  #
  # Logger which prevents log calls to Console in IE.
  # Author: rbuckheit
  #
  class Logger

    @get : (moduleName) ->
      return new Logger(moduleName)

    constructor : (@moduleName) ->

    log : (message, args...) ->
      args = args.map(JSON.stringify)
      window.console && console.log("[#{@moduleName}] #{message} #{args}")

    info : (message, args...) ->
      args = args.map(JSON.stringify)
      window.console && console.info("[#{@moduleName}] #{message} #{args}")

    warn : (message, args...) ->
      args = args.map(JSON.stringify)
      window.console && console.warn("[#{@moduleName}] #{message} #{args}")

    error : (message, args...) ->
      args = args.map(JSON.stringify)
      window.console && console.error("[#{@moduleName}] #{message} #{args}")

    debug: (message, args...) ->
      args = args.map(JSON.stringify)
      window.console && console.debug("[#{@moduleName}] #{message} #{args}")

  return Logger
