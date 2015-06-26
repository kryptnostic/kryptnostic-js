(
  {
    baseUrl  : 'js/src',
    name     : "cs!soteria",
    out      : "build/soteria.js",
    optimize : "none",
    wrap     : true,
    paths    : {
      "forge.min"                          : "../lib/forge.min",
      "jquery"                             : "../lib/jquery",
      "pako"                               : "../lib/pako",
      "cookies"                            : "../lib/cookies",
      "src/utils"                          : "./utils",
      "src/password-crypto"                : "./password-crypto",
      "src/rsa-crypto"                     : "./rsa-crypto",
      "src/aes-crypto"                     : "./aes-crypto",
      "src/abstract-crypto"                : "./abstract-crypto",
      'soteria.session-storage-credential' : './session-storage-credential',
      'soteria.crypto-service-loader'      : './crypto-service-loader'
    },
    packages : [
      {
        name     : 'cs',
        location : '../../bower_components/require-cs',
        main     : 'cs'
      },
      {
        name     : 'coffee-script',
        location : '../../bower_components/coffeescript',
        main     : 'extras/coffee-script'
      }
    ],
  },

  {
    baseUrl  : 'js/src',
    name     : "cs!soteria",
    out      : "build/soteria.min.js",
    optimize : "uglify",
    wrap     : true,
    paths    : {
      "forge.min"                          : "../lib/forge.min",
      "jquery"                             : "../lib/jquery",
      "pako"                               : "../lib/pako",
      "cookies"                            : "../lib/cookies",
      "src/utils"                          : "./utils",
      "src/password-crypto"                : "./password-crypto",
      "src/rsa-crypto"                     : "./rsa-crypto",
      "src/aes-crypto"                     : "./aes-crypto",
      "src/abstract-crypto"                : "./abstract-crypto",
      'soteria.session-storage-credential' : './session-storage-credential',
      'soteria.crypto-service-loader'      : './crypto-service-loader'
    },
    packages : [
      {
        name     : 'cs',
        location : '../../bower_components/require-cs',
        main     : 'cs'
      },
      {
        name     : 'coffee-script',
        location : '../../bower_components/coffeescript',
        main     : 'extras/coffee-script'
      }
    ],
  }
)