import * as http from 'http';
import * as https from 'https';
// @todo (enhancement? / possible code smell): use axios. Don't use fetch, don't use default http / https.
/**
 * Note: The REST API that this ClientAPI communicates with allows transactions
 * from exactly one of the 3 clients: Shopper, Retailer, CouponIssuer.
 */
export default class ClientAPI {
    /**
     * @constructor
     * @param {string?} hostname The hostname that represents the back-end REST API endpoint.
     * @param {number?} port The port of the back-end REST API endpoint.
     * @param {Boolean?} usingTLS True if using TLS (https), False otherwise (http)
     */
    constructor(hostname, port, usingTLS) {
        /**
         * Creates a shopper in the database associated with the REST API.
         *
         * @param {string} name
         * @param {string} email
         * @param {string} password
         * @param {string} verifyPassword
         * @param {({ status: number, headers: http.IncomingHttpHeaders, body: string }) => void} [cb] do stuff here that depends on the shopper first being created
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.createShopper = (name, email, password, verifyPassword, cb) => this.apiHelpers.createUser('createShopper', name, email, password, verifyPassword, cb);
        /**
         * Creates a retailer in the database associated with the REST API.
         *
         * @param {string} name
         * @param {string} email
         * @param {string} password
         * @param {string} verifyPassword
         * @param {({ status: number, headers: http.IncomingHttpHeaders, body: string }) => void} [cb] do stuff here that depends on the retailer first being created
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.createRetailer = (name, email, password, verifyPassword, cb) => this.apiHelpers.createUser('createRetailer', name, email, password, verifyPassword, cb);
        /**
         * Creates a couponIssuer in the database associated with the REST API.
         *
         * @param {string} password
         * @param {string} verifyPassword
         * @param {({ status: number, headers: http.IncomingHttpHeaders, body: string }) => void} [cb] do stuff here that depends on the couponIssuer first being created
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.createCouponIssuer = (password, verifyPassword, cb) => this.apiHelpers.createCouponIssuer(password, verifyPassword, cb);
        /**
         * 'Logs' the shopper in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a shopper has privileges to do.
         *
         * @param {string} username shopper's email
         * @param {string} password shopper's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} [cb] a basic authentication token is passed here for client to make authenticated calls (as an authorized shopper) to REST API.
         * @returns {(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)}
         */
        this.loginShopper = (username, password, cb) => this.apiHelpers.loginUser('loginShopper', username, password, cb);
        /**
         * 'Logs' the retailer in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a retailer has privileges to do.
         *
         * @param {string} username retailer's email
         * @param {string} password retailer's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} [cb] a basic authentication token is passed here for client to make authenticated calls (as an authorized retailer) to REST API.
         * @returns {(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)}
         */
        this.loginRetailer = (username, password, cb) => this.apiHelpers.loginUser('loginRetailer', username, password, cb);
        /**
         * 'Logs' the couponIssuer in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a couponIssuer has privileges to do.
         *
         * @param {string} username couponIssuer's name (should just be "CouponIssuer")
         * @param {string} password couponIssuer's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} [cb] a basic authentication token is passed here for client to make authenticated calls (as an authorized couponIssuer) to REST API.
         * @returns {(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)}
         */
        this.loginCouponIssuer = (password, cb) => this.apiHelpers.loginCouponIssuer(password, cb);
        /**
         * Updates (or inserts if not yet in database) the shopper's preferences.
         *
         * @param {ShopperPreferencesRequest} shopperPrefs
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.upsertShopperPreferences = (shopperPrefs, token, cb) => this.apiHelpers.postWithAuthentication('preferences', shopperPrefs, token, cb);
        /**
         * Update's a shopper's location. This can only be done by an authorized shopper.
         *
         * @param {UpdateShopperLocationRequest} shopperLocation
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.updateShopperLocation = (shopperLocation, token, cb) => this.apiHelpers.postWithAuthentication('updateShopperLocation', shopperLocation, token, cb);
        /**
         * Gets the relevant coupons for a particular shopper. This can only be done by an authorized shopper.
         *
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.getRelevantCoupons = (token, cb) => this.apiHelpers.postWithAuthentication('getRelevantCoupons', {}, token, cb);
        /**
         * Processes the coupon for a shopper. This can only be done by an authorized retailer.
         * This is meant to signify that a coupon has been processed (by a retailer) during a
         * transaction at a retail store.
         *
         * @param {ShopperToCouponRequest} shopperToCoupon
         * @param {string} token get this from callback passed to loginRetailer
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.processCoupon = (shopperToCoupon, token, cb) => this.apiHelpers.postWithAuthentication('processCoupon', shopperToCoupon, token, cb);
        /**
         * Posts a new coupon to the database. This can only be done by an authorized couponIssuer
         * (namely, the backend service that will be creating coupons on behalf of each participating
         * retailer, based on a set of criteria that each retailer will need to provide).
         *
         * @param {CreateCouponRequest} createCouponRequest
         * @param {string} token get this from callback passed to loginCouponIssuer
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.postCoupon = (createCouponRequest, token, cb) => this.apiHelpers.postWithAuthentication('postCoupon', createCouponRequest, token, cb);
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
        this.apiHelpers = {
            baseUrl: 'http://riyadshauk.com:8080',
            hostname: 'riyadshauk.com',
            port: 8080,
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
                postCoupon: '/relevantCoupon',
            },
            postWithOptions: (options, onEnd, data, cb) => {
                if (cb !== undefined && !(cb instanceof Function)) {
                    console.error((new Error(`Invalid cb passed in!`)).stack);
                }
                else if (cb === undefined) {
                    return new Promise((resolve, reject) => {
                        const lib = this.apiHelpers.baseUrl.startsWith('https') ? https : http;
                        const req = lib.request(options, (res) => {
                            // if (res.statusCode < 200 || res.statusCode > 299) {
                            //     reject(new Error('Failed to load page, status code: ' + res.statusCode));
                            // }
                            const body = [];
                            res.on('data', (chunk) => body.push(chunk));
                            res.on('end', () => {
                                resolve(onEnd(res, body.join('')));
                                console.log('No more data in response.');
                            });
                        });
                        if (data !== undefined)
                            req.write(data);
                        req.on('error', (err) => reject(err));
                        req.end();
                    });
                }
                else {
                    const lib = this.apiHelpers.baseUrl.startsWith('https') ? https : http;
                    const req = lib.request(options, (res) => {
                        res.setEncoding('utf8');
                        const body = [];
                        res.on('data', (chunk) => {
                            body.push(chunk);
                        });
                        res.on('end', () => {
                            cb(onEnd(res, body.join('')));
                            console.log('No more data in response.');
                        });
                    });
                    req.on('error', (e) => {
                        console.error(`problem with request: ${e.message}`);
                    });
                    if (data !== undefined)
                        req.write(data);
                    req.end();
                }
            },
            createUser: (routeKey, name, email, password, verifyPassword, cb) => {
                const body = {
                    name,
                    email,
                    password,
                    verifyPassword,
                };
                const query = Object.keys(body).reduce((acc, key) => acc += `${encodeURIComponent(key)}=${encodeURIComponent(body[key])}&`, '');
                const options = {
                    hostname: this.apiHelpers.hostname,
                    port: this.apiHelpers.port,
                    path: this.apiHelpers.routes[routeKey],
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Content-Length': Buffer.byteLength(query),
                    }
                };
                const onEnd = (res, data) => {
                    return { status: res.statusCode, headers: res.headers, body: data };
                };
                return this.apiHelpers.postWithOptions(options, onEnd, query, cb);
            },
            createCouponIssuer: (password, verifyPassword, cb) => {
                return this.apiHelpers.createUser('createCouponIssuer', 'CouponIssuer', 'blahEmail', password, verifyPassword, cb);
            },
            loginUser: (routeKey, username, password, cb) => {
                const options = {
                    hostname: this.apiHelpers.hostname,
                    port: this.apiHelpers.port,
                    path: this.apiHelpers.routes[routeKey],
                    method: 'POST',
                    auth: `${username}:${password}`,
                };
                const onEnd = (res, data) => {
                    try {
                        const json = JSON.parse(data);
                        const keys = Object.keys(json);
                        let id = -1;
                        keys.forEach((key) => {
                            if (key === 'shopperID' || key === 'retailerID' || key === 'couponIssuerID')
                                id = json[key];
                        });
                        return { token: json.string, tokenExpiration: json.expiresAt, id };
                    }
                    catch (e) {
                        console.error('loginUser json\n', e.stack);
                    }
                };
                return this.apiHelpers.postWithOptions(options, onEnd, undefined, cb);
            },
            loginCouponIssuer: (password, cb) => {
                return this.apiHelpers.loginUser('loginCouponIssuer', 'CouponIssuer', password, cb);
            },
            postWithAuthentication: (routeKey, body, token, cb) => {
                const query = Object.keys(body).reduce((acc, key) => acc += `${encodeURIComponent(key)}=${encodeURIComponent(body[key])}&`, '');
                const options = {
                    hostname: this.apiHelpers.hostname,
                    port: this.apiHelpers.port,
                    path: this.apiHelpers.routes[routeKey],
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Content-Length': Buffer.byteLength(query),
                        'Authorization': `Bearer ${token}`,
                    },
                };
                const onEnd = (res, data) => {
                    return { status: res.statusCode, headers: res.headers, body: data };
                };
                return this.apiHelpers.postWithOptions(options, onEnd, query, cb);
            }
        };
        this.apiHelpers.hostname = hostname || 'riyadshauk.com';
        this.apiHelpers.port = port || 8080;
        this.apiHelpers.baseUrl = `${usingTLS ? 'https' : 'http'}://${this.apiHelpers.hostname}:${String(this.apiHelpers.port)}`;
        console.log(`Successfully instantiated a clientAPI with a back-end REST API endpoint of ${this.apiHelpers.baseUrl} (Note: using ${usingTLS ? 'HTTPS' : 'HTTP'}!)`);
    }
}
