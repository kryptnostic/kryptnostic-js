define 'kryptnostic.object-utils', [
  'require'
], (require) ->

  CHILD_SEPARATOR = '~'

  createChildId = (id, index) ->
    return "#{id}#{CHILD_SEPARATOR}#{index}"

  isChildId = (id) ->
    return id.indexOf(CHILD_SEPARATOR) >= 0

  getChildIndex = (id) ->
    return _.parseInt(_.last(id.split(CHILD_SEPARATOR)))

  return {
    isChildId,
    createChildId,
    getChildIndex
  }
