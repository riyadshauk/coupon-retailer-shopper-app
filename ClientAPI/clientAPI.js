// This is an unmaintained transpilation from clientAPI.ts (run "npm run build-es5" to generate this file directly from clientAPI.ts)
"use strict";
exports.__esModule = true;
/**
 * Note: The REST API that this ClientAPI communicates with allows transactions
 * from exactly one of the 3 clients: Shopper, Retailer, CouponIssuer.
 */
var ClientAPI = /** @class */ (function () {
    function ClientAPI(baseUrl) {
        var _this = this;
        this.baseUrl = 'riyadshauk.com:8080/'; // default value
        this.b64EncodeUnicode = function (str) {
            // first we use encodeURIComponent to get percent-encoded UTF-8,
            // then we convert the percent encodings into raw bytes which
            // can be fed into btoa.
            return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function toSolidBytes(match, p1) {
                return String.fromCharCode(Number('0x' + p1));
            }));
        };
        this.routes = {
            createShopper: 'shopper',
            createRetailer: 'retailer',
            /* This is only allowed to be set once, and the name will always be "CouponIssuer",
            * regardless of whatever name the client provides */
            createCouponIssuer: 'couponIssuer',
            loginShopper: 'shopperLogin',
            loginRetailer: 'retailerRetailer',
            loginCouponIssuer: 'couponIssuerLogin',
            /* Note: To be 'logged in', provide the Bearer Token recieved in the JSON response
            * from the above log-in endpoints. */
            /* == endpoints only accessible by logged in Shopper == */
            upsertShopperPreferences: 'preferences',
            updateShopperLocation: 'location',
            getRelevantCoupons: 'relevantCoupons',
            /* == endpoint only accessible by logged in Retailer == */
            processCoupon: 'processCoupon',
            /* == endpoint only accessible by logged in CouponIssuer == */
            postCoupon: 'relevantCoupon'
        };
        this.genericEmptyRequest = function () {
            var headers = new Headers();
            headers.append('content-type', 'application/json; charset=UTF-8');
            return {
                headers: headers,
                method: 'POST'
            };
        };
        this.createUser = function (routeKey, name, email, password, verifyPassword) {
            var generic = _this.genericEmptyRequest();
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
            var req = new Request(_this.baseUrl + _this.routes[routeKey], reqInit);
            fetch(req)
                .then(function (data) { return data.json(); })
                .then(function (res) { return console.log(res); });
        };
        this.loginUser = function (routeKey, username, password, cb) {
            if (!(cb instanceof Function)) {
                throw new Error('cb must be a valid Function in order to store the authorization token upon login');
            }
            var req = _this.genericEmptyRequest();
            // req.headers.append('Authorization', `Basic: ${Buffer.from(`${username}:${password}`).tostring('base64')}`);
            req.headers.append('Authorization', "Basic: " + _this.b64EncodeUnicode(username + ":" + password));
            fetch(_this.baseUrl + _this.routes[routeKey], req)
                .then(function (data) { return data.json(); })
                .then(function (res) {
                cb({ token: res.string, id: res.id });
            });
        };
        this.postWithAuthentication = function (routeKey, body, token) {
            var generic = _this.genericEmptyRequest();
            generic.headers.append('Authorization', "Basic: " + token);
            var reqInit = {
                headers: generic.headers,
                method: generic.method,
                body: JSON.stringify(body)
            };
            var req = new Request(_this.baseUrl + _this.routes[routeKey], reqInit);
            fetch(_this.baseUrl + _this.routes[routeKey], req)
                .then(function (data) { return data.json(); })
                .then(function (res) {
                // should be nothing to do at this point
                console.log('res:', res);
            });
        };
        this.createShopper = function (name, email, password, verifyPassword) {
            _this.createUser('createShopper', name, email, password, verifyPassword);
        };
        this.createRetailer = function (name, email, password, verifyPassword) {
            _this.createUser('createRetailer', name, email, password, verifyPassword);
        };
        this.createCouponIssuer = function (name, email, password, verifyPassword) {
            _this.createUser('createCouponIssuer', name, email, password, verifyPassword);
        };
        /**
         *
         * @param {string} username shopper's email
         * @param {string} password shopper's password
         * @param {({token: string, id: Number}) => Any} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized shopper) to REST API.
         */
        this.loginShopper = function (username, password, cb) {
            _this.loginUser('loginShopper', username, password, cb);
        };
        /**
         *
         * @param {string} username retailer's email
         * @param {string} password retailer's password
         * @param {(token: string) => Any} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized retailer) to REST API.
         */
        this.loginRetailer = function (username, password, cb) {
            _this.loginUser('loginRetailer', username, password, cb);
        };
        /**
         *
         * @param {string} username couponIssuer's name (should just be "CouponIssuer")
         * @param {string} password couponIssuer's password
         * @param {(token: string) => Any} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized couponIssuer) to REST API.
         */
        this.loginCouponIssuer = function (username, password, cb) {
            _this.loginUser('loginCouponIssuer', username, password, cb);
        };
        /**
         *
         * @param {ShopperPreferencesRequest} shopperPrefs
         * @param {string} token get this from callback passed to loginShopper
         */
        this.upsertShopperPreferences = function (shopperPrefs, token) {
            _this.postWithAuthentication('preferences', shopperPrefs, token);
        };
        /**
         *
         * @param {UpdateShopperLocationRequest} shopperLocation
         * @param {string} token get this from callback passed to loginShopper
         */
        this.updateShopperLocation = function (shopperLocation, token) {
            _this.postWithAuthentication('updateShopperLocation', shopperLocation, token);
        };
        /**
         *
         * @param {string} token get this from callback passed to loginShopper
         */
        this.getRelevantCoupons = function (token) {
            _this.postWithAuthentication('getRelevantCoupons', {}, token);
        };
        /**
         *
         * @param {ShopperToCouponRequest} shopperToCoupon
         * @param {string} token get this from callback passed to loginRetailer
         */
        this.processCoupon = function (shopperToCoupon, token) {
            _this.postWithAuthentication('processCoupon', shopperToCoupon, token);
        };
        /**
         *
         * @param {CreateCouponRequest} createCouponRequest
         * @param {string} token get this from callback passed to loginCouponIssuer
         */
        this.postCoupon = function (createCouponRequest, token) {
            _this.postWithAuthentication('postCoupon', createCouponRequest, token);
        };
        this.baseUrl = baseUrl;
    }
    return ClientAPI;
}());
exports["default"] = ClientAPI;
