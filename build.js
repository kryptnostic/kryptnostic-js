(
  {
    baseUrl                : 'js/src',
    name                   : 'cs!kryptnostic',
    out                    : 'dist/kryptnostic.js',
    optimize               : 'none',
    wrap                   : false,
    findNestedDependencies : true,
    paths                  : {
      'bluebird'    : '../../bower_components/bluebird/js/browser/bluebird',
      'forge'       : '../../bower_components/forge/js/forge.min',
      'axios'       : '../../bower_components/axios/dist/axios.amd.min',
      'jscache'     : '../../bower_components/jscache/index',
      'lodash'      : '../../bower_components/lodash/lodash',
      'pako'        : '../../bower_components/pako/dist/pako',
      'require'     : '../../bower_components/requirejs/require',
      'loglevel'    : '../../bower_components/loglevel/dist/loglevel',
      'revalidator' : '../../node_modules/revalidator/lib/revalidator',
      'function-name': '../../bower_components/function-name/index'
    },
    // these dependencies are used in the build process but not in the dist.
    exclude  : [ 'cs', 'coffee-script' ],
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
