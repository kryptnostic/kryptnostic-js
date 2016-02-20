# kryptnostic.js

kryptnostic.js is an SDK for secure search, sharing, and storage on the [Kryptnostic](www.kryptnostic.com) platform. No private keys are sent to the server in plaintext, and all user data is encrypted with 256-bit AES. It uses state-of-the-art advancements in fully homomorphic encryption to provide searchable encryption over text data.


[![build status](https://img.shields.io/travis/kryptnostic/kryptnostic-js.svg?branch=develop&style=flat-square)](https://travis-ci.org/kryptnostic/kryptnostic-js)
[![npm version](https://img.shields.io/npm/v/kryptnostic-js.svg?style=flat-square)](https://www.npmjs.org/package/kryptnostic-js)
[![bower version](https://img.shields.io/bower/v/kryptnostic-js.svg?style=flat-square)](http://bower.io/search/?q=kryptnostic-js)

##Getting Started
###Installation
To install the latest version:

```
npm install --save kryptnostic-js
```
###Loading
To load the library:
```
var KJS = require('./node_modules/kryptnostic-js/dist/kryptnostic.umd.js');
```

###Configuration
Currently, you must configure the library with valid URLs for 2 backend services.
To run against our production services:
```
KJS.ConfigurationService.set({
  servicesUrlV2 : 'https://kodex.im/services2/v2',
  heraclesUrlV2 : 'https://kodex.im/heracles2/v2'
});
```

###Registration
To register:
```
KJS.RegistrationClient.register({ 'krypto@kryptnostic.com', 'krypto', 'mansbestfriend1^' })
.then(function() {
    // confirm successful registration.
})
.catch(function() {
  // registration failed :(
});
```

##API
```
interface  KJS {
  ConfigurationService    ConfigurationService;
  AuthenticationService   AuthenticationService;
  UserDirectoryApi        UserDirectoryApi;
  RegistrationClient'     RegistrationClient;
  UserDirectoryApi        UserDirectoryApi;
}

interface  ConfigurationService {
  void                    set(Config);
  String                  get(ConfigKey);
}

enum       ConfigKey = {'servicesUrlV2', 'heraclesUrlV2'}

dictionary Config {
  String?                 ConfigKey;
  ...
}

interface  RegistrationClient {
  Promise<void>           register: ( RegistrationRequest );
}

dictionary RegistrationRequest {
  String                  email;
  String                  name;
  String                  password;
}
```

##Developing
See docs/development.md
