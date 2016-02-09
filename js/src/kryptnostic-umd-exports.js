var AuthenticationService = require('kryptnostic.authentication-service');
var ConfigurationService  = require('kryptnostic.configuration');
var RegistrationApi       = require('kryptnostic.registration-api');
var RegistrationClient    = require('kryptnostic.registration-client');
var UserDirectoryApi      = require('kryptnostic.user-directory-api');

module.exports = {
  'AuthenticationService' : AuthenticationService,
  'ConfigurationService'  : ConfigurationService,
  'RegistrationApi'       : RegistrationApi,
  'RegistrationClient'    : RegistrationClient,
  'UserDirectoryApi'      : UserDirectoryApi
};
