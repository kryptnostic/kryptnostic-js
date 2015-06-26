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
sudo npm install -g karma
sudo npm install -g karma-cli
sudo npm install -g requirejs
bower install
npm install
```

## building

Builds use the require.js optimizer.
Building will produce `soteria.js` and `soteria.min.js` in the `build` directory.

```
./build.sh
```

## unit testing

Karma and Jasmine are used for unit testing.

To start the unit tests, run

`npm run test`

## browser testing

For end-to-end testing, build using `build.sh` then open index.html in the browser.

On chrome you need to disable web security to allow the page to communicate with locally running Kryptnostic servers.

`open /Applications/Google\ Chrome.app -n --args --disable-web-security`

Alternatively, you can use the CORS extension or create a proxy.
