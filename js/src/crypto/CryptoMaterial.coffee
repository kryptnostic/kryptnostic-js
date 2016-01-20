define 'kryptnostic.crypto-material', [], (require) ->

  CryptoMaterial = {
    IV       : 'IV',
    TAG      : 'TAG',
    CONTENTS : 'CONTENTS',
    SALT     : 'SALT'
  }

  DEFAULT_REQUIRED_CRYPTO_MATERIAL = [
    CryptoMaterial.IV,
    CryptoMaterial.CONTENTS,
    CryptoMaterial.SALT
  ]

  return {
    DEFAULT_REQUIRED_CRYPTO_MATERIAL: DEFAULT_REQUIRED_CRYPTO_MATERIAL
  }
