(
  {
    baseUrl                : 'js/src',
    name                   : 'cs!soteria',
    out                    : 'build/soteria.js',
    optimize               : 'none',
    wrap                   : false,
    findNestedDependencies : true,
    paths                  : {
      'bluebird'    : '../../bower_components/bluebird/js/browser/bluebird',
      'forge'       : '../../bower_components/forge/js/forge.min',
      'jquery'      : '../../bower_components/jquery/dist/jquery',
      'lodash'      : '../../bower_components/lodash/lodash',
      'pako'        : '../../bower_components/pako/dist/pako',
      'require'     : '../../bower_components/requirejs/require',
      'loglevel'    : '../../bower_components/loglevel/dist/loglevel',
      'revalidator' : '../../node_modules/revalidator/lib/revalidator'
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
    ]
  }
)
