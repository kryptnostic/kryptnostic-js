define 'kryptnostic.object-utils', [
  'require'
], (require) ->

  createChildId = (id, index) ->
    return "#{id}~#{index}"

  return { createChildId }
