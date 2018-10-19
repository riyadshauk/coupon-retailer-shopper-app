import ClientAPI from '../clientAPI';
import coupons from './coupons';
import shopperPrefs from './shopperPrefs';

const hostname = 'localhost';
const port = 8080;
const api = new ClientAPI(hostname, port);

const SHOPPER = 'shopper';
const RETAILER = 'retailer';
const COUPONISSUER = 'couponIssuer';

const errfn = err => console.error(`Promise ERROR: ${err.stack}`);

const postCoupons = (couponIssuerToken, cb?: Function) => {
    console.log(`couponIssuer with token of ${couponIssuerToken} is logged in.`);
    return new Promise((resolve, reject) => {
        coupons.forEach((coupon) => {
            api.postCoupon(coupon, couponIssuerToken)
            .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
                console.log('postCoupon complete, response:', res);
            })
            .catch((e) => errfn(e));
        });
        resolve();
    });
};

/**
 * 
 * @param userType ie: 'retailer' || 'shopper' || 'couponIssuer'
 * @param quantity ie: 10
 */
const createUser = (userType: string, quantity?: number = 10, cb?: Function) => {
    let usersCreated = 0;
    let usersCreatedFired = false;
    let create: Function;
    switch (userType) {
        case RETAILER:
            create = api.createRetailer;
            break;
        case SHOPPER:
            create = api.createShopper;
            break;
        case COUPONISSUER:
            create = api.createCouponIssuer;
            return create('123', '123')
            .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
                const checkDone = (nextAction) => nextAction();
                if (cb === undefined) return new Promise((resolve, reject) => checkDone(resolve));
                else return checkDone(cb);
            })
            .catch((e) => errfn(e));
            break;
        default:
            break;
    }
    if (userType !== COUPONISSUER) {
        return new Promise((resolve, reject) => {
            for (let i = 1; i <= quantity; i++) {
                console.log(`Running createUser for ${userType+i}`);
                create(`${userType+i}`, `${userType+i}@example.com`, '123', '123')
                .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
                    usersCreated++;
                    const checkDone = (nextAction) => {
                        if (usersCreated === quantity && !usersCreatedFired) {
                            usersCreatedFired = true;
                            console.log(`All ${userType}s created!`);
                            nextAction();
                        }
                    };
                    if (cb === undefined) setTimeout(() => checkDone(resolve), 1000);
                    else setTimeout(() => checkDone(cb), 1000);
                })
                .catch((e) => errfn(e));
            }
        })
    }
};

/**
 * 
 * @param userType ie: 'retailer' || 'shopper' || 'couponIssuer'
 * @param quantity ie: 10
 */
const loginUser = (userType: string, quantity?: number = 10, cb?: Function) => {
    let usersLoggedIn = 0;
    let usersLoggedInFired = false;
    let login: Function;
    switch (userType) {
        case RETAILER:
            login = api.loginRetailer;
            break;
        case SHOPPER:
            login = api.loginShopper;
            break;
        case COUPONISSUER:
            login = api.loginCouponIssuer;
            login('123')
            .then((res: {token: string, tokenExpiration: string, id: Number}) => {
                console.log(`loginUser: couponIssuer logged in with token of ${res.token}`);
                if (cb === undefined) return new Promise((resolve, reject) => resolve(res.token));
                else return cb(res.token);
            })
            break;
        default:
            break;
    }
    if (userType !== COUPONISSUER) {
        const userTokens = {};
        return new Promise((resolve, reject) => {
            for (let i = 1; i <= quantity; i++) {
                login(`${userType+i}@example.com`, '123')
                .then((res: {token: string, tokenExpiration: string, id: Number}) => {
                    userTokens[res.id] = res.token;
                    usersLoggedIn++
                    console.log(`${userType+i} logged in with response:`, res);
                    const checkDone = (nextAction) => {
                        if (usersLoggedIn === quantity && !usersLoggedInFired) {
                            usersLoggedInFired = true;
                            console.log(`All ${userType}s logged in!`);
                            nextAction(userTokens);
                        }
                    };
                    if (cb === undefined) setTimeout(() => checkDone(resolve), 1000);
                    else setTimeout(() => checkDone(cb), 1000);
                })
                .catch((e) => errfn(e));
            }
        });
    }
};

const doUserActions = (userType: String, apiCall: Function, objectCreator: Function, userTokens, cb?: Function) => {
    let actions = 0;
    let actionsDoneFired = false;

    console.log(`Inside doUserActions with userType ${userType}, apiCall ${apiCall}, objectCreator ${objectCreator}, cb ${cb}, userTokens ${JSON.stringify(userTokens)}`);

    // @todo: fix bug where userTokens is empty!!

    return new Promise((resolve, reject) => {
        Object.keys(userTokens).forEach((id, idx) => {
            apiCall(objectCreator(), userTokens[id])
            .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
                console.log(`${userType} action complete, response:`, res);
                actions++;
                const checkDone = (nextAction) => {
                    if (actions === 10 && !actionsDoneFired) {
                        actionsDoneFired = true;
                        console.log(`All ${userType} actions done!`);
                        nextAction()
                    }
                };
                if (cb === undefined) setTimeout(() => checkDone(resolve), 1000);
                else setTimeout(() => checkDone(cb), 1000);
            })
            .catch((e) => errfn(e));
        })
    });
};

const doShopperActions = (shopperTokens, cb?: Function) => doUserActions('shopper', api.upsertShopperPreferences, shopperPrefs, shopperTokens, cb);

const generateShopperToCoupon: ShopperToCouponRequest = () => {
    const couponID = Math.ceil(Math.random() * 9);
    const isDiscountPercentage = Math.random() < 0.5 ? true : false;
    return {
        shopperID: Math.ceil(Math.random() * 9),
        couponID: couponID,
        isValid: true,
        isRedeemed: false,
        start: Date.now(),
        end: Date.now() + 10000,
        progress: 0,
        earningUnit: Math.random() < 0.33 ? 'steps' : Math.random() < 0.5 ? 'purchases' : 'dollars spent',
        earningGoal: Math.ceil(Math.random() * 25),
        name: 'coupon name here',
        product: 'some product info? superfluous category?',
        title: coupons[couponID].title,
        productDiscountPercentage: isDiscountPercentage ? Math.random() * 85 : -1,
        productDiscount: !isDiscountPercentage ? Math.floor(Math.random() * 4 + 1) * 5 : -1,
        timesProcessed: 0,
    };
};

const doRetailerActions = (retailerTokens, cb?: Function) => doUserActions('retailer', api.processCoupon, generateShopperToCoupon, retailerTokens, cb);

// Now we can finally test HTTP GET with DB query
const getRelevantCoupons = (shopperTokens, cb?: Function) => {
    let responsesReceived = 0;
    let allResponsesReceived = false;
    return new Promise((resolve, reject) => {
        Object.keys(shopperTokens).forEach((id, idx) => {
            api.getRelevantCoupons(shopperTokens[id])
            .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
                console.log('getRelevantCoupons response:', res);
                responsesReceived++;
                const checkDone = (nextAction) => {
                    if (responsesReceived === 10 && !allResponsesReceived) {
                        allResponsesReceived = true;
                        console.log('All relevant coupons received!');
                        nextAction();
                    }
                }
                if (cb === undefined) setTimeout(() => checkDone(resolve), 1000);
                else setTimeout(() => checkDone(cb), 1000);
            })
            .catch((e) => errfn(e));
        })
    });
};

interface ShopperToCouponRequest {
    /// Reference to Shopper that belongs to this ShopperToCoupon.
    shopperID: Number;
    /// Reference to Coupon that belongs to this ShopperToCoupon.
    couponID: Number;
    start: Date;
    end: Date;
    // progress = some multiple of earningUnit divided by earningGoal
    progress: Number;
    // ie: "steps"
    earningUnit: String;
    // ie: 100 (for 100 steps)
    earningGoal: Number;
    isValid: Boolean;
    // initially must be initialized to false
    isRedeemed: Boolean;
    product: String;
    name: String;
    title: String;
    // if productDiscountPercentage < 0, it's invalid
    productDiscountPercentage: Number;
    // if productDiscount < 0, it's invalid
    productDiscount: Number;
    timesProcessed: Number;
}

/**
 * Actually execute the API queries to populate the Database here
 */
createUser(COUPONISSUER)
.then(() => loginUser(COUPONISSUER))
.then((couponIssuerToken) => postCoupons(couponIssuerToken))
.catch((e) => errfn(e));

createUser(SHOPPER, 10)
.then(() => loginUser(SHOPPER, 10))
.then((shopperTokens) => {
    doShopperActions(shopperTokens)

    createUser(RETAILER, 10)
    .then(() => loginUser(RETAILER, 10))
    .then((retailerTokens) => doRetailerActions(retailerTokens))
    .then(() => getRelevantCoupons(shopperTokens))
    .catch((e) => errfn(e));
})
.catch((e) => errfn(e));