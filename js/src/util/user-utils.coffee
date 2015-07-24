define 'kryptnostic.user-utils', [
  'require'
  'lodash'
], (require) ->

  _ = require 'lodash'

  PRINCIPAL_SEPARATOR = '|'

  #
  # Utility module for user accounts.
  # Author: rbuckheit
  #

  principalToComponents = (principal) ->
    split = principal.split(PRINCIPAL_SEPARATOR)
    [realm, username, rest...] = split

    unless _.isEmpty(rest)
      throw new Error 'too many components in principal string'
    unless !!realm and !!username
      throw new Error 'invalid principal string'

    return {realm, username}

  componentsToPrincipal = ({realm, username}) ->
    if !realm or !username
      throw new Error 'missing realm or username'
    return [realm, username].join(PRINCIPAL_SEPARATOR)

  componentsToUserKey = ({realm, username}) ->
    return {name: username, realm: realm}

  return {
    componentsToPrincipal
    principalToComponents
    componentsToUserKey
  }
