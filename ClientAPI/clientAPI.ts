import './interfaces/request';
import './interfaces/types';
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
    constructor(hostname?: string, port?: number, usingTLS?: Boolean) {
        this.apiHelpers.hostname = hostname || 'riyadshauk.com';
        this.apiHelpers.port = port || 8080;
        this.apiHelpers.baseUrl = `${usingTLS ? 'https' : 'http'}://${this.apiHelpers.hostname}:${String(this.apiHelpers.port)}`;
        console.log(`Successfully instantiated a clientAPI with a back-end REST API endpoint of ${this.apiHelpers.baseUrl} (Note: using ${usingTLS ? 'HTTPS' : 'HTTP'}!)`);

        /**
         * Creates a shopper in the database associated with the REST API.
         * 
         * @param {string} name
         * @param {string} email
         * @param {string} password
         * @param {string} verifyPassword
         * @param {({ status: number, headers: string, body: string }) => void} [cb] do stuff here that depends on the shopper first being created
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.createShopper = (name: string, email: string, password: string, verifyPassword: string, cb?: ({ status: number, headers: string, body: string }) => void): 
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? =>
            this.apiHelpers.createUser('createShopper', name, email, password, verifyPassword, cb);
        
        /**
         * Creates a retailer in the database associated with the REST API.
         * 
         * @param {string} name
         * @param {string} email
         * @param {string} password
         * @param {string} verifyPassword
         * @param {({ status: number, headers: string, body: string }) => void} [cb] do stuff here that depends on the retailer first being created
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.createRetailer = (name: string, email: string, password: string, verifyPassword: string, cb?: ({ status: number, headers: string, body: string }) => void):
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? => {
            this.apiHelpers.createUser('createRetailer', name, email, password, verifyPassword, cb);
        
        /**
         * Creates a couponIssuer in the database associated with the REST API.
         * 
         * @param {string} password
         * @param {string} verifyPassword
         * @param {({ status: number, headers: string, body: string }) => void} [cb] do stuff here that depends on the couponIssuer first being created
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.createCouponIssuer = (password: string, verifyPassword: string, cb?: ({ status: number, headers: string, body: string }) => void):
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? =>
            this.apiHelpers.createCouponIssuer(password, verifyPassword, cb);
        
        /**
         * 'Logs' the shopper in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a shopper has privileges to do.
         * 
         * @param {string} username shopper's email
         * @param {string} password shopper's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} [cb] a basic authentication token is passed here for client to make authenticated calls (as an authorized shopper) to REST API.
         * @returns {(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)}
         */
        this.loginShopper = (username: string, password: string, cb?: ({token: string, tokenExpiration: string, id: Number}) => void):
        void | Promise<{ token: string, tokenExpiration: string, id: Number }>? =>
            this.apiHelpers.loginUser('loginShopper', username, password, cb);
        
        /**
         * 'Logs' the retailer in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a retailer has privileges to do.
         * 
         * @param {string} username retailer's email
         * @param {string} password retailer's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} [cb] a basic authentication token is passed here for client to make authenticated calls (as an authorized retailer) to REST API.
         * @returns {(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)}
         */
        this.loginRetailer = (username: string, password: string, cb?: ({token: string, tokenExpiration: string, id: Number}) => void):
        void | Promise<{ token: string, tokenExpiration: string, id: Number }>? =>
            this.apiHelpers.loginUser('loginRetailer', username, password, cb);
        
        /**
         * 'Logs' the couponIssuer in by calling the provided callback, cb, with an object with a property named `token`.
         * This token will be needed in order to do things that only a couponIssuer has privileges to do.
         * 
         * @param {string} username couponIssuer's name (should just be "CouponIssuer")
         * @param {string} password couponIssuer's password
         * @param {({token: string, tokenExpiration: string, id: Number}) => void} [cb] a basic authentication token is passed here for client to make authenticated calls (as an authorized couponIssuer) to REST API.
         * @returns {(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)}
         */
        this.loginCouponIssuer = (password: string, cb?: ({token: string, tokenExpiration: string, id: Number}) => void):
        void | Promise<{ token: string, tokenExpiration: string, id: Number }>? =>
            this.apiHelpers.loginCouponIssuer(password, cb);
        
        /**
         * Updates (or inserts if not yet in database) the shopper's preferences.
         * 
         * @param {ShopperPreferencesRequest} shopperPrefs 
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.upsertShopperPreferences = (shopperPrefs: ShopperPreferencesRequest, token: string, cb?: ({ status: number, headers: string, body: string }) => void):
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? =>
            this.apiHelpers.postWithAuthentication('preferences', shopperPrefs, token, cb);
        
        
        /**
         * Update's a shopper's location. This can only be done by an authorized shopper.
         * 
         * @param {UpdateShopperLocationRequest} shopperLocation 
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.updateShopperLocation = (shopperLocation: UpdateShopperLocationRequest, token: string, cb?: ({ status: number, headers: string, body: string }) => void):
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? =>
            this.apiHelpers.postWithAuthentication('updateShopperLocation', shopperLocation, token, cb);
        
        /**
         * Gets the relevant coupons for a particular shopper. This can only be done by an authorized shopper.
         * 
         * @param {string} token get this from callback passed to loginShopper
         * @param { status: number, headers: string, body: JSON } [cb] sends back response and possibly relevant body to client from REST API
         * @returns {(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)}
         */
        this.getRelevantCoupons = (token: string, cb?: ({ status: number, headers: string, body: string }) => void):
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? =>
            this.apiHelpers.postWithAuthentication('getRelevantCoupons', {}, token, cb);
        
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
        this.processCoupon = (shopperToCoupon: ShopperToCouponRequest, token: string, cb?: ({ status: number, headers: string, body: string }) => void):
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? =>
            this.apiHelpers.postWithAuthentication('processCoupon', shopperToCoupon, token, cb);
        
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
        this.postCoupon = (createCouponRequest: CreateCouponRequest, token: string, cb?: ({ status: number, headers: string, body: string }) => void):
        void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? =>
            this.apiHelpers.postWithAuthentication('postCoupon', createCouponRequest, token, cb);
    }
}

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
const apiHelpers = {
    baseUrl: 'http://riyadshauk.com:8080', // default value
    hostname: 'riyadshauk.com',
    port: 8080,
    routes: { // All routes are POST requests, unless otherwise noted.
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
        getRelevantCoupons: '/relevantCoupons', /* This is the only GET, naturally */

        /* == endpoint only accessible by logged in Retailer == */
        processCoupon: '/processCoupon',

        /* == endpoint only accessible by logged in CouponIssuer == */
        postCoupon: '/relevantCoupon',
    },
    postWithOptions: (options: any,
        onEnd: (res: Response, data: string) => T,
        data?: string,
        cb?: (T) => void) => {

            // @todo: don't let this server-side error occur by calling from client-side:
            //      [ERROR] [HTTP] HTTPResponse sent while HTTPRequest had unconsumed chunked data. [HTTPServer.swift:208]

        if (cb === undefined) {
            // see: https://www.tomas-dvorak.cz/posts/nodejs-request-without-dependencies/
            return new Promise((resolve, reject) => {
                const lib = this.apiHelpers.baseUrl.startsWith('https') ? https : http;
                const req: http.ClientRequest = lib.request(options, (res: Response) => {
                    // handle http errors
                    if (res.statusCode < 200 || res.statusCode > 299) {
                        reject(new Error('Failed to load page, status code: ' + res.statusCode));
                    }
                    // temporary data holder
                    const body = [];
                    // on every content chunk, push it to the data array
                    res.on('data', (chunk) => body.push(chunk));
                    // we are done, resolve promise with those joined chunks
                    res.on('end', () => {
                        // resolve({ status: res.statusCode, headers: res.headers, body: body.join('') });
                        resolve(onEnd(res, body.join('')));
                    });
                });
                // if (data !== undefined && options.headers && options.headers['Content-Type'] !== 'application/json; charset=UTF-8') req.write(data);
                // if (options.headers && options.headers['Content-Type'] === 'application/json; charset=UTF-8') req.end(data);
                // else req.end();
                if (data !== undefined) req.write(data);
                req.end();
                // handle connection errors of the request
                req.on('error', (err) => reject(err))
            });
        } else {
            const lib = this.apiHelpers.baseUrl.startsWith('https') ? https : http;
            const req: http.ClientRequest = lib.request(options, (res: Response) => {
                // console.log(`STATUS: ${res.statusCode}`);
                // console.log(`HEADERS: ${JSON.stringify(res.headers)}`);
                res.setEncoding('utf8');
                const body = [];
                res.on('data', (chunk: string) => {
                //   console.log(`BODY: ${chunk}`);
                    body.push(chunk);
                });
                res.on('end', () => {
                    // cb({ status: res.statusCode, headers: res.headers, body: body.join('') });
                    cb(onEnd(res, body.join('')));
                    console.log('No more data in response.');
                });
            });
            req.on('error', (e) => {
                console.error(`problem with request: ${e.message}`);
            });
            // if (data !== undefined && options.headers && options.headers['Content-Type'] !== 'application/json; charset=UTF-8') req.write(data);
            // if (options.headers && options.headers['Content-Type'] === 'application/json; charset=UTF-8') req.end(data);
            // else req.end();
            if (data !== undefined) req.write(data);
            req.end();
        }
    },
    createUser: (routeKey: string, name: string, email: string, password: string, verifyPassword: string, cb?: ({ status: number, headers: string, body: string }) => void):
            void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? => {

        const body = {
            name,
            email,
            password,
            verifyPassword,
        };

        const query = Object.keys(body).reduce((acc, key) => acc += `${encodeURIComponent(key)}=${encodeURIComponent(body[key])}&`, '');

        const options = { // see: https://nodejs.org/api/http.html#http_http_request_options_callback
            hostname: this.apiHelpers.hostname,
            port: this.apiHelpers.port,
            path: this.apiHelpers.routes[routeKey],
            method: 'POST',
            headers: {
                // 'Content-Type': 'application/json; charset=UTF-8',
                // 'Content-Length': Buffer.byteLength(body)
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(query),
            }
        };

        const onEnd = (res: Response, data: string) => {
            return { status: res.statusCode, headers: res.headers, body: data };
        };

        // return this.apiHelpers.postWithOptions<{ status: number, headers: http.IncomingHttpHeaders, body: string }>(options, onEnd, undefined, cb);
        return this.apiHelpers.postWithOptions<{ status: number, headers: http.IncomingHttpHeaders, body: string }>(options, onEnd, query, cb);
    },
    createCouponIssuer: (password: string, verifyPassword: string, cb?: ({ status: number, headers: http.IncomingHttpHeaders, body: string }) => void):
            void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? => {
        this.apiHelpers.createUser('createCouponIssuer', 'CouponIssuer', 'blahEmail', password, verifyPassword, cb);
    },
    loginUser: (routeKey: string, username: string, password: string, 
        cb?: ({ token: string, tokenExpiration: string, id: Number }) => void): 
            void | Promise<{ token: string, tokenExpiration: string, id: Number }> => {

        const options = { // see: https://nodejs.org/api/http.html#http_http_request_options_callback
            hostname: this.apiHelpers.hostname,
            port: this.apiHelpers.port,
            path: this.apiHelpers.routes[routeKey],
            method: 'POST',
            auth: `${username}:${password}`,
        };

        const onEnd = (res: Response, data: string) => {
            try {
                const json = JSON.parse(data);
                const keys = Object.keys(json);
                let id = -1;
                keys.forEach((key) => {
                    if (key === 'shopperID' || key === 'retailerID' || key === 'couponIssuerID') id = json[key];
                });
                return { token: json.string, tokenExpiration: json.expiresAt, id };
            } catch (e) {
                throw new Error('loginUser json\n' + e.stack);
            }
        }

        return this.apiHelpers.postWithOptions<{ token: string, tokenExpiration: string, id: Number }>(options, onEnd, undefined, cb);

    },
    loginCouponIssuer: (password: string, cb: ({token: string, tokenExpiration: string, id: Number}) => void) => {
        this.apiHelpers.loginUser('loginCouponIssuer', 'CouponIssuer', password, cb);
    },
    postWithAuthentication: (routeKey: string, body: any, token: string, cb?: ({ status: number, headers: string, body: string }) => void): 
                            void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>? => {

        const query = Object.keys(body).reduce((acc, key) => acc += `${encodeURIComponent(key)}=${encodeURIComponent(body[key])}&`, '');

        const options = {
            hostname: this.apiHelpers.hostname,
            port: this.apiHelpers.port,
            path: this.apiHelpers.routes[routeKey],
            method: 'POST',
            headers: { // see: https://nodejs.org/api/http.html#http_http_request_options_callback
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(query),
                'Authorization': `Bearer ${token}`,
            },
        };

        const onEnd = (res: Response, data: string) => {
            return { status: res.statusCode, headers: res.headers, body: data };
        };

        return this.apiHelpers.postWithOptions<{ status: number, headers: http.IncomingHttpHeaders, body: string }>(options, onEnd, query, cb);
    }
};