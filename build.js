(
  {
    baseUrl                : 'js/src',
    name                   : 'cs!soteria',
    out                    : 'build/soteria.js',
    optimize               : 'none',
    wrap                   : false,
    findNestedDependencies : true,
    paths                  : {
      'cookies'     : '../lib/cookies',
      'forge.min'   : '../lib/forge.min',
      'jquery'      : '../lib/jquery',
      'pako'        : '../lib/pako',
      'lodash'      : '../lib/lodash',
      'revalidator' : '../lib/revalidator',
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