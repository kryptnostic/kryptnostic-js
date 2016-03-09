/*
 * kryptnostic.js webpack config
 */
const pkg = require('./package.json');
const path = require('path');
const webpack = require('webpack');

/*
 *
 * constants
 *
 */

const FILES = {
  KJS_ENTRY_POINT: path.join(__dirname, 'src/app.js')
};

const PATHS = {
  DIST: path.join(__dirname, 'dist'),
  SOURCE: path.join(__dirname, 'src'),
  TEST: path.join(__dirname, 'test')
};

const KJS_BANNER = `
${pkg.name} - v${pkg.version}
${pkg.description}
${pkg.homepage}

Copyright (c) 2014-2016, Kryptnostic, Inc. All rights reserved.
`;

/*
 *
 * plugins
 *
 */

const kjsBannerPlugin = new webpack.BannerPlugin(
  KJS_BANNER,
  {
    entryOnly: true
  }
);

const kjsDefinePlugin = new webpack.DefinePlugin({
  __VERSION__: JSON.stringify(`v${pkg.version}`)
});

const kjsUglifyJsPlugin = new webpack.optimize.UglifyJsPlugin({
  compress: {
    warnings: true
  }
});

/*
 *
 * config
 *
 */

module.exports = {
  entry: FILES.KJS_ENTRY_POINT,
  context: PATHS.SOURCE,
  output: {
    path: PATHS.DIST,
    library: 'KJS',
    libraryTarget: 'umd',
    filename: 'kryptnostic.js',
    sourceMapFilename: 'kryptnostic.js.map'
  },
  module: {
    loaders: [
      {
        loader: 'babel',
        test: /\.js$/,
        include: [
          PATHS.SOURCE,
          PATHS.TEST
        ]
      }
    ],
    noParse: [
      /krypto\.js$/
    ]
  },
  resolve: {
    extensions: ['', '.js']
  },
  plugins: [
    kjsBannerPlugin,
    kjsDefinePlugin,
    kjsUglifyJsPlugin
  ],
  bail: true
};
