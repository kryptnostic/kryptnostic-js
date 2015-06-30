(
  {
    baseUrl  : 'js/src',
    name     : 'cs!soteria',
    out      : 'build/soteria.js',
    optimize : 'none',
    wrap     : false,
    paths    : {
      'cookies'                       : '../lib/cookies',
      'forge.min'                     : '../lib/forge.min',
      'jquery'                        : '../lib/jquery',
      'pako'                          : '../lib/pako',
      'lodash'                        : '../lib/lodash',
      'soteria.crypto-service-loader' : './crypto-service-loader',
      'soteria.security-utils'        : './utils',
      'src/abstract-crypto'           : './abstract-crypto',
      'src/aes-crypto'                : './aes-crypto',
      'src/password-crypto'           : './password-crypto',
      'src/rsa-crypto'                : './rsa-crypto',
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