define 'kryptnostic.authentication-stage', [
  'require'
], (require) ->

  #
  # Enumeration of authentication stages, used to indicate the state of auth progress.
  # Author: rbuckheit
  #

  AuthenticationStage = {
    DERIVE_CREDENTIAL  : 'deriving credential'
    RSA_KEYGEN         : 'generating rsa keypair'
    DERIVE_KEYPAIR     : 'deriving rsa keypair'
    COMPLETED          : 'authentication complete'
  }

  return AuthenticationStage
