(
  {
    baseUrl                : 'js/src',
    name                   : 'cs!soteria',
    out                    : 'build/soteria.js',
    optimize               : 'none',
    wrap                   : false,
    findNestedDependencies : true,
    paths                  : {
      'require'     : '../../bower_components/requirejs/require',
      'forge.min'   : '../../bower_components/forge/js/forge.min',
      'jquery'      : '../../bower_components/jquery/dist/jquery',
      'pako'        : '../../bower_components/pako/dist/pako',
      'lodash'      : '../../bower_components/lodash/lodash',
      'revalidator' : '../../node_modules/revalidator/lib/revalidator',
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
