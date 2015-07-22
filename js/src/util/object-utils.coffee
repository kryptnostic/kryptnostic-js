define 'soteria.object-utils', [
  'require'
], (require) ->

  createChildId = (id, index) ->
    return "#{id}~#{index}"

  return { createChildId }
