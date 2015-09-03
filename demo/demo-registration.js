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

  registrationClient.register(userRegistrationRequest)
  .then(function(){
    console.info('user registration is complete!');
  });
});
