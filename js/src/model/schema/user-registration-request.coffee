define 'kryptnostic.schema.user-registration-request', [], ->

  properties: {
    password: {
      type        : 'string'
      description : 'user credential (password hash)'
      required    : true
      allowEmpty  : false
    }
    email : {
      type        : 'string'
      description : 'user email address'
      required    : true
      allowEmpty  : false
    }
    name : {
      type        : 'string'
      description : 'user given name'
      required    : true
      allowEmpty  : false
    }
    confirmationEmailNeeded : {
      type        : 'boolean'
      description : 'flag for indicating whether confirmation email is needed'
      required    : true
      allowEmpty  : false
    }
  }
