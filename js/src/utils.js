define(['require', 'cookies'], function(require) {
    'use strict';
    var Cookies = require('cookies');

    var SecurityUtils = {};
    SecurityUtils.PRINCIPAL_COOKIE = 'X-Kryptnostic-Principal';
    SecurityUtils.CREDENTIAL_COOKIE = 'X-Kryptnostic-Credential';

    SecurityUtils.wrapRequest = function(request) {
        request.beforeSend = function(xhr) {
            xhr.setRequestHeader(SecurityUtils.PRINCIPAL_COOKIE, Cookies.get(SecurityUtils.PRINCIPAL_COOKIE));
            xhr.setRequestHeader(SecurityUtils.CREDENTIAL_COOKIE, Cookies.get(SecurityUtils.CREDENTIAL_COOKIE));
        }
        return request;
    };

    return SecurityUtils;
});