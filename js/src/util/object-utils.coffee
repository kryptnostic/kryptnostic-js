define 'kryptnostic.object-utils', [
  'require'
], (require) ->

  CHILD_SEPARATOR = '~'

  createChildId = (id, index) ->
    return "#{id}#{CHILD_SEPARATOR}#{index}"

  isChildId = (id) ->
    if id?
      return id.indexOf(CHILD_SEPARATOR) >= 0
    else
      return false

  childIdToParent = (id) ->
    if id?
      index = id.indexOf(CHILD_SEPARATOR)
      if (index >= 0)
        return id.slice(0, index)
      else
        return id
    else
      return null

  getChildIndex = (id) ->
    if id?
      splitArray = id.split(CHILD_SEPARATOR)
      if splitArray.length > 1
        return _.parseInt(_.last(splitArray))
      else
        return -1
    else
      return -1

  return {
    isChildId,
    createChildId,
    getChildIndex,
    childIdToParent
  }
