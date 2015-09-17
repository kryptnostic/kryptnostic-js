//
// Provides an example of how to register a new user account.
// Author: rbuckheit
//

require([
  'require',
  'kryptnostic.configuration',
  'kryptnostic.registration-client',
  'kryptnostic.user-registration-request'
], function(require) {

  var Config                  = require('kryptnostic.configuration');
  var RegistrationClient      = require('kryptnostic.registration-client');
  var UserRegistrationRequest = require('kryptnostic.user-registration-request');

  Config.set({
    servicesUrl : 'http://localhost:8081/v1',
    heraclesUrl : 'http://localhost:8082/v1'
  });

  var registrationClient      = new RegistrationClient();
  var userRegistrationRequest = new UserRegistrationRequest({
    email    : 'new-user@kryptnostic.com',
    password : 'kryptodoge1!',
    name     : 'Bob User'
  });
  var userRegistrationRequest1 = new UserRegistrationRequest({
    email    : 'demo@kryptnostic.com',
    password : 'demo',
    name     : 'Demo User'
  });
  var userRegistrationRequest2 = new UserRegistrationRequest({
    email    : 'test@kryptnostic.com',
    password : 'demo',
    name     : 'Test User'
  });
  registrationClient.register(userRegistrationRequest)
  registrationClient.register(userRegistrationRequest1)
  registrationClient.register(userRegistrationRequest2)
  .then(function(){
    console.info('user registration is complete!');
  });
});
