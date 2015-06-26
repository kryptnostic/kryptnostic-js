define(['require', 'cookies'], function(require) {
    'use strict';
    var Cookies                     = require('cookies');
    var SecurityUtils               = {};
    SecurityUtils.PRINCIPAL_COOKIE  = 'X-Kryptnostic-Principal';
    SecurityUtils.CREDENTIAL_COOKIE = 'X-Kryptnostic-Credential';

    SecurityUtils.wrapRequest = function(request) {
        request.beforeSend = function(xhr) {
            // TODO: better cred storage strategy
            var principal = sessionStorage.getItem('soteria.principal')     // Cookies.get(SecurityUtils.PRINCIPAL_COOKIE)
            var credential = sessionStorage.getItem('soteria.credential');   // Cookies.get(SecurityUtils.CREDENTIAL_COOKIE)

            xhr.setRequestHeader(SecurityUtils.PRINCIPAL_COOKIE, principal);
            xhr.setRequestHeader(SecurityUtils.CREDENTIAL_COOKIE, credential);
        }
        return request;
    };

    return SecurityUtils;
});