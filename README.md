# soteria

JavaScript client for Kryptnostic crypto services.

## development

This project uses:

1. Bower and NPM for package management.
2. require.js for package management.
3. r.js optimizer for builds.
4. Karma and Jasmine for unit testing.


To set up, install node.js and npm, then run the following:

```
sudo npm install -g bower
bower install
npm install
```

## conventions

1. Files exporting classes should be named in `UpperCamelCase` (one class per file).
2. Files exporting anything else should be named in `lower-kebab-case`.
3. AMD module definition names should be prefixed with `soteria`, e.g. `soteria.storage-client`
4. When using require for module definitions, prefer explicit `require(name)` calls to destructuring.

## building

Builds use the require.js optimizer.
Building will produce `soteria.js` and `soteria.min.js` in the `build` directory.

```
./build.sh
```

## unit testing

Karma and Jasmine are used for unit testing.

To start the unit tests, run

```
./test.sh
```

## common problems

1. Circular require.js dependencies will cause `require` calls to fail.. You will see an error like:

```
 Error: Module name "soteria.my-module" has not been loaded yet for context: _
```

This can be fixed by tracing dependencies of `soteria.my-module` and breaking the cycle.

## browser testing

For end-to-end testing, build using `build.sh` then open `demo/index.html` in the browser.

On chrome you need to disable web security to allow the page to communicate with locally running Kryptnostic servers.

`open /Applications/Google\ Chrome.app -n --args --disable-web-security`

Alternatively, you can use the CORS extension or create a proxy.
