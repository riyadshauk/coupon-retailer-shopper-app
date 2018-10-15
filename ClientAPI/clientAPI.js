"use strict";
var fetch = require("node-fetch");
var http = require("http");
var https = require("https");
// @todo (enhancement? / possible code smell): use axios. Don't use fetch, don't use default http / https.
/**
 * Note: The REST API that this ClientAPI communicates with allows transactions
 * from exactly one of the 3 clients: Shopper, Retailer, CouponIssuer.
 */
var ClientAPI = /** @class */ (function () {
    /**
     * @constructor
     * @param {string?} hostname The hostname that represents the back-end REST API endpoint.
     * @param {number?} port The port of the back-end REST API endpoint.
     * @param {Boolean?} usingTLS True if using TLS (https), False otherwise (http)
     */
    function ClientAPI(hostname, port, usingTLS) {
        /**
         * Creates a shopper in the database associated with the REST API.
         *
         * @param {string} name
         * @param {string} email
         * @param {string} password
         * @param {string} verifyPassword
         */
        this.createShopper = function (name, email, password, verifyPassword) {
            return apiHelpers.createUser('createShopper', name, email, password, verifyPassword);
        };
        /**
         * Creates a retailer in the database associated with the REST API.
         *
         * @param {string} name
         * @param {string} email
         * @param {string} password
         * @param {string} verifyPassword
         */
        this.createRetailer = function (name, email, password, verifyPassword) {
            return apiHelpers.createUser('createRetailer', name, email, password, verifyPassword);
        };
        /**
         * Creates a couponIssuer in the database associated with the REST API.
         *
         * @param {string} password
         * @param {string} verifyPassword
         */
        this.createCouponIssuer = function (password, verifyPassword) {
            return apiHelpers.createCouponIssuer(password, verifyPassword);
        };
        /**
         * 'Logs' the shopper in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a shopper has privileges to do.
         *
         * @param {string} username shopper's email
         * @param {string} password shopper's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized shopper) to REST API.
         */
        this.loginShopper = function (username, password, cb) {
            return apiHelpers.loginUser('loginShopper', username, password, cb);
        };
        /**
         * 'Logs' the retailer in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a retailer has privileges to do.
         *
         * @param {string} username retailer's email
         * @param {string} password retailer's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized retailer) to REST API.
         */
        this.loginRetailer = function (username, password, cb) {
            return apiHelpers.loginUser('loginRetailer', username, password, cb);
        };
        /**
         * 'Logs' the couponIssuer in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a couponIssuer has privileges to do.
         *
         * @param {string} username couponIssuer's name (should just be "CouponIssuer")
         * @param {string} password couponIssuer's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized couponIssuer) to REST API.
         */
        this.loginCouponIssuer = function (password, cb) {
            return apiHelpers.loginCouponIssuer(password, cb);
        };
        /**
         * Updates (or inserts if not yet in database) the shopper's preferences.
         *
         * @param {ShopperPreferencesRequest} shopperPrefs
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } cb sends back response and possibly relevant body to client from REST API
         */
        this.upsertShopperPreferences = function (shopperPrefs, token, cb) {
            return apiHelpers.postWithAuthentication('preferences', shopperPrefs, token, cb);
        };
        /**
         * Update's a shopper's location. This can only be done by an authorized shopper.
         *
         * @param {UpdateShopperLocationRequest} shopperLocation
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } cb sends back response and possibly relevant body to client from REST API
         */
        this.updateShopperLocation = function (shopperLocation, token, cb) {
            return apiHelpers.postWithAuthentication('updateShopperLocation', shopperLocation, token, cb);
        };
        /**
         * Gets the relevant coupons for a particular shopper. This can only be done by an authorized shopper.
         *
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } cb sends back response and possibly relevant body to client from REST API
         */
        this.getRelevantCoupons = function (token, cb) {
            return apiHelpers.postWithAuthentication('getRelevantCoupons', {}, token, cb);
        };
        /**
         * Processes the coupon for a shopper. This can only be done by an authorized retailer.
         * This is meant to signify that a coupon has been processed (by a retailer) during a
         * transaction at a retail store.
         *
         * @param {ShopperToCouponRequest} shopperToCoupon
         * @param {string} token get this from callback passed to loginRetailer
         * @param { status: number, headers: string, body: JSON } cb sends back response and possibly relevant body to client from REST API
         */
        this.processCoupon = function (shopperToCoupon, token, cb) {
            return apiHelpers.postWithAuthentication('processCoupon', shopperToCoupon, token, cb);
        };
        /**
         * Posts a new coupon to the database. This can only be done by an authorized couponIssuer
         * (namely, the backend service that will be creating coupons on behalf of each participating
         * retailer, based on a set of criteria that each retailer will need to provide).
         *
         * @param {CreateCouponRequest} createCouponRequest
         * @param {string} token get this from callback passed to loginCouponIssuer
         * @param { status: number, headers: string, body: JSON } cb sends back response and possibly relevant body to client from REST API
         */
        this.postCoupon = function (createCouponRequest, token, cb) {
            return apiHelpers.postWithAuthentication('postCoupon', createCouponRequest, token, cb);
        };
        apiHelpers.hostname = hostname || 'riyadshauk.com';
        apiHelpers.port = port || 8080;
        apiHelpers.baseUrl = (usingTLS ? 'https' : 'http') + "://" + apiHelpers.hostname + ":" + String(apiHelpers.port);
        console.log("Successfully instantiated a clientAPI with a back-end REST API endpoint of " + apiHelpers.baseUrl + " (Note: using " + (usingTLS ? 'HTTPS' : 'HTTP') + "!)");
    }
    return ClientAPI;
}());
module.exports = ClientAPI;
/**
 * These functions are essentially private, but are still accessible to the ClientAPI class because
 * they are in the COVE (closed over variable environment.
 * (see: https://www.google.com/search?q=closures+in+javascript .)
 *
 * Also, since the JavaScript engine hoists statement declarations,
 * it's completely valid to declare and define these apiHelpers down
 * below/after they're actually invoked/consumed (in ClientAPI, above).
 * (see: https://www.google.com/search?q=hoisting+in+javascript)
 */
var apiHelpers = {
    baseUrl: 'http://riyadshauk.com:8080',
    hostname: 'riyadshauk.com',
    port: 8080,
    b64EncodeUnicode: function (str) {
        // first we use encodeURIComponent to get percent-encoded UTF-8,
        // then we convert the percent encodings into raw bytes which
        // can be fed into btoa.
        return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function toSolidBytes(match, p1) {
            return String.fromCharCode(Number('0x' + p1));
        }));
    },
    routes: {
        createShopper: '/shopper',
        createRetailer: '/retailer',
        /* This is only allowed to be set once, and the name will always be "CouponIssuer",
        * regardless of whatever name the client provides */
        createCouponIssuer: '/couponIssuer',
        loginShopper: '/shopperLogin',
        loginRetailer: '/retailerLogin',
        loginCouponIssuer: '/couponIssuerLogin',
        /* Note: To be 'logged in', provide the Bearer Token recieved in the JSON response
        * from the above log-in endpoints. */
        /* == endpoints only accessible by logged in Shopper == */
        upsertShopperPreferences: '/preferences',
        updateShopperLocation: '/location',
        getRelevantCoupons: '/relevantCoupons',
        /* == endpoint only accessible by logged in Retailer == */
        processCoupon: '/processCoupon',
        /* == endpoint only accessible by logged in CouponIssuer == */
        postCoupon: '/relevantCoupon'
    },
    genericEmptyRequest: function () {
        var headers = new fetch.Headers();
        headers.append('content-type', 'application/json; charset=UTF-8');
        return {
            headers: headers,
            method: 'POST'
        };
    },
    createUser: function (routeKey, name, email, password, verifyPassword) {
        var generic = apiHelpers.genericEmptyRequest();
        var reqInit = {
            headers: generic.headers,
            method: generic.method,
            body: JSON.stringify({
                name: name,
                email: email,
                password: password,
                verifyPassword: verifyPassword
            })
        };
        // const req = new fetch.Request(apiHelpers.baseUrl + apiHelpers.routes[routeKey], reqInit);
        fetch["default"](apiHelpers.baseUrl + apiHelpers.routes[routeKey], reqInit)
            .then(function (data) { return data.json(); })
            .then(function (res) { return console.log(res); });
    },
    createCouponIssuer: function (password, verifyPassword) {
        apiHelpers.createUser('createCouponIssuer', 'CouponIssuer', 'blahEmail', password, verifyPassword);
    },
    postWithOptions: function (options, onEnd, data, cb) {
        // @todo: don't let this server-side error occur by calling from client-side:
        //      [ERROR] [HTTP] HTTPResponse sent while HTTPRequest had unconsumed chunked data. [HTTPServer.swift:208]
        if (cb === undefined) {
            // see: https://www.tomas-dvorak.cz/posts/nodejs-request-without-dependencies/
            return new Promise(function (resolve, reject) {
                var lib = apiHelpers.baseUrl.startsWith('https') ? https : http;
                var req = lib.request(options, function (res) {
                    // handle http errors
                    if (res.statusCode < 200 || res.statusCode > 299) {
                        reject(new Error('Failed to load page, status code: ' + res.statusCode));
                    }
                    // temporary data holder
                    var body = [];
                    // on every content chunk, push it to the data array
                    res.on('data', function (chunk) { return body.push(chunk); });
                    // we are done, resolve promise with those joined chunks
                    res.on('end', function () {
                        // resolve({ status: res.statusCode, headers: res.headers, body: body.join('') });
                        resolve(onEnd(res, body.join('')));
                    });
                });
                if (data !== undefined)
                    req.write(data, 'utf8');
                // handle connection errors of the request
                req.on('error', function (err) { return reject(err); });
            });
        }
        else {
            var lib = apiHelpers.baseUrl.startsWith('https') ? https : http;
            var req = lib.request(options, function (res) {
                // console.log(`STATUS: ${res.statusCode}`);
                // console.log(`HEADERS: ${JSON.stringify(res.headers)}`);
                res.setEncoding('utf8');
                var body = [];
                res.on('data', function (chunk) {
                    //   console.log(`BODY: ${chunk}`);
                    body.push(chunk);
                });
                res.on('end', function () {
                    // cb({ status: res.statusCode, headers: res.headers, body: body.join('') });
                    cb(onEnd(res, body.join('')));
                    console.log('No more data in response.');
                });
            });
            req.on('error', function (e) {
                console.error("problem with request: " + e.message);
            });
            if (data !== undefined)
                req.write(data);
            req.end();
        }
    },
    loginUser: function (routeKey, username, password, cb) {
        var options = {
            hostname: apiHelpers.hostname,
            port: apiHelpers.port,
            path: apiHelpers.routes[routeKey],
            method: 'POST',
            auth: username + ":" + password
        };
        var onEnd = function (res, data) {
            try {
                var json_1 = JSON.parse(data);
                var keys = Object.keys(json_1);
                var id_1 = -1;
                keys.forEach(function (key) {
                    if (key === 'shopperID' || key === 'retailerID' || key === 'couponIssuerID')
                        id_1 = json_1[key];
                });
                return { token: json_1.string, tokenExpiration: json_1.expiresAt, id: id_1 };
            }
            catch (e) {
                throw new Error('loginUser json\n' + e.stack);
            }
        };
        return apiHelpers.postWithOptions(options, onEnd, undefined, cb);
    },
    loginCouponIssuer: function (password, cb) {
        apiHelpers.loginUser('loginCouponIssuer', 'CouponIssuer', password, cb);
    },
    postWithAuthentication: function (routeKey, body, token, cb) {
        var query = '';
        Object.keys(body).forEach(function (key) { return query += encodeURIComponent(key) + '=' + encodeURIComponent(body[key]) + '&'; });
        var options = {
            hostname: apiHelpers.hostname,
            port: apiHelpers.port,
            path: apiHelpers.routes[routeKey],
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(query),
                'Authorization': "Bearer " + token
            }
        };
        var onEnd = function (res, data) {
            return { status: res.statusCode, headers: res.headers, body: data };
        };
        return apiHelpers.postWithOptions(options, onEnd, query, cb);
    }
};
