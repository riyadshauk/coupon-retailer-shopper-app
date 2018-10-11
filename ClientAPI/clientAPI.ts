import './interfaces/request';

/**
 * Note: The REST API that this ClientAPI communicates with allows transactions 
 * from exactly one of the 3 clients: Shopper, Retailer, CouponIssuer.
 */
export default class ClientAPI {
    private baseUrl = 'riyadshauk.com:8080/'; // default value
    constructor(baseUrl: string) {
        this.baseUrl = baseUrl;
    }
    private b64EncodeUnicode = (str: string) => { // (see: https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding#Solution_1_–_escaping_the_string_before_encoding_it)
        // first we use encodeURIComponent to get percent-encoded UTF-8,
        // then we convert the percent encodings into raw bytes which
        // can be fed into btoa.
        return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
            function toSolidBytes(match: string, p1: string) {
                return String.fromCharCode(Number('0x' + p1));
        }));
    };
    private routes = { // All routes are POST requests, unless otherwise noted.
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
        getRelevantCoupons: 'relevantCoupons', /* This is the only GET, naturally */

        /* == endpoint only accessible by logged in Retailer == */
        processCoupon: 'processCoupon',

        /* == endpoint only accessible by logged in CouponIssuer == */
        postCoupon: 'relevantCoupon',
    };
    private genericEmptyRequest = (): {headers: Headers, method: string} => {
        const headers = new Headers();
        headers.append('content-type', 'application/json; charset=UTF-8');
        return {
            headers: headers,
            method: 'POST',
        }
    };
    private createUser = (routeKey: string, name: string, email: string, password: string, verifyPassword: string) => {
        const generic = this.genericEmptyRequest();
        const reqInit = {
            headers: generic.headers,
            method: generic.method,
            body: JSON.stringify({
                name,
                email,
                password,
                verifyPassword,
            })
        };
        const req = new Request(this.baseUrl + this.routes[routeKey], reqInit);
        fetch(req)
        .then(data => data.json())
        .then(res => console.log(res));
    };
    private loginUser = (routeKey: string, username: string, password: string, cb: ({token: string, id: Number}) => void) => {
        if (!(cb instanceof Function)) {
            throw new Error('cb must be a valid Function in order to store the authorization token upon login');
        }
        const req = this.genericEmptyRequest();
        // req.headers.append('Authorization', `Basic: ${Buffer.from(`${username}:${password}`).tostring('base64')}`);
        req.headers.append('Authorization', `Basic: ${this.b64EncodeUnicode(`${username}:${password}`)}`);
        fetch(this.baseUrl + this.routes[routeKey], req)
        .then(data => data.json())
        .then(res => {
            cb({token: res.string, id: res.id});
        });
    };
    private postWithAuthentication = (routeKey: string, body: any, token: string) => {
        const generic = this.genericEmptyRequest();
        generic.headers.append('Authorization', `Basic: ${token}`);
        const reqInit = {
            headers: generic.headers,
            method: generic.method,
            body: JSON.stringify(body),
        };
        const req = new Request(this.baseUrl + this.routes[routeKey], reqInit);
        fetch(this.baseUrl + this.routes[routeKey], req)
        .then(data => data.json())
        .then(res => {
            // should be nothing to do at this point
            console.log('res:', res);
        });
    };
    
    public createShopper = (name: string, email: string, password: string, verifyPassword: string) => {
        this.createUser('createShopper', name, email, password, verifyPassword);
    };
    
    public createRetailer = (name: string, email: string, password: string, verifyPassword: string) => {
        this.createUser('createRetailer', name, email, password, verifyPassword);
    };
    
    public createCouponIssuer = (name: string, email: string, password: string, verifyPassword: string) => {
        this.createUser('createCouponIssuer', name, email, password, verifyPassword);
    };
    
    /**
     * 
     * @param {string} username shopper's email
     * @param {string} password shopper's password
     * @param {({token: string, id: Number}) => Any} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized shopper) to REST API.
     */
    public loginShopper = (username: string, password: string, cb: ({token: string, id: Number}) => void) => {
        this.loginUser('loginShopper', username, password, cb);
    };
    
    /**
     * 
     * @param {string} username retailer's email
     * @param {string} password retailer's password
     * @param {(token: string) => Any} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized retailer) to REST API.
     */
    public loginRetailer = (username: string, password: string, cb: ({token: string, id: Number}) => void) => {
        this.loginUser('loginRetailer', username, password, cb);
    };
    
    /**
     * 
     * @param {string} username couponIssuer's name (should just be "CouponIssuer")
     * @param {string} password couponIssuer's password
     * @param {(token: string) => Any} cb a basic authentication token is passed here for client to make authenticated calls (as an authorized couponIssuer) to REST API.
     */
    public loginCouponIssuer = (username: string, password: string, cb: ({token: string, id: Number}) => void) => {
        this.loginUser('loginCouponIssuer', username, password, cb);
    };
    
    /**
     * 
     * @param {ShopperPreferencesRequest} shopperPrefs 
     * @param {string} token get this from callback passed to loginShopper
     */
    public upsertShopperPreferences = (shopperPrefs: ShopperPreferencesRequest, token: string) => {
        this.postWithAuthentication('preferences', shopperPrefs, token);
    };
    
    
    /**
     * 
     * @param {UpdateShopperLocationRequest} shopperLocation 
     * @param {string} token get this from callback passed to loginShopper
     */
    public updateShopperLocation = (shopperLocation: UpdateShopperLocationRequest, token: string) => {
        this.postWithAuthentication('updateShopperLocation', shopperLocation, token);
    };
    
    /**
     * 
     * @param {string} token get this from callback passed to loginShopper
     */
    public getRelevantCoupons = (token: string) => {
        this.postWithAuthentication('getRelevantCoupons', {}, token);
    };
    
    /**
     * 
     * @param {ShopperToCouponRequest} shopperToCoupon 
     * @param {string} token get this from callback passed to loginRetailer
     */
    public processCoupon = (shopperToCoupon: ShopperToCouponRequest, token: string) => {
        this.postWithAuthentication('processCoupon', shopperToCoupon, token);
    };
    
    /**
     * 
     * @param {CreateCouponRequest} createCouponRequest 
     * @param {string} token get this from callback passed to loginCouponIssuer
     */
    public postCoupon = (createCouponRequest: CreateCouponRequest, token: string) => {
        this.postWithAuthentication('postCoupon', createCouponRequest, token);
    };
}