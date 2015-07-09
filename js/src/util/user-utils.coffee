define 'soteria.user-utils', [
  'require'
], (require) ->

  PRINCIPAL_SEPARATOR = '|'

  #
  # Utility module for user accounts.
  # Author: rbuckheit
  #

  principalToComponents = (principal) ->
    [realm, username] = principal.split(PRINCIPAL_SEPARATOR)
    if !realm or !username
      throw new Error 'missing realm or username'
    return {realm, username}

  componentsToPrincipal = ({realm, username}) ->
    if !realm or !username
      throw new Error 'missing realm or username'
    return [realm, username].join(PRINCIPAL_SEPARATOR)

  return {
    componentsToPrincipal
    principalToComponents
  }
