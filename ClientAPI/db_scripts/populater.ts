import { EventEmitter } from 'events'; // see: https://nodejs.org/dist/latest-v10.x/docs/api/events.html
import ClientAPI from '../clientAPI';
import coupons from './coupons';
import shopperPrefs from './shopperPrefs';

const hostname = 'localhost';
const port = 8080;
const api = new ClientAPI(hostname, port);

let shoppersCreated = 0;
const shopperTokens = {};
let shopperTokensCount = 0;
let shoppersCreatedFired = false;
let shoppersLoggedInFired = false;

const errfn = err => console.error(`Promise ERROR: ${err}`);

class Observer extends EventEmitter {};
const observer = new Observer();
observer.on('shoppersCreated', () => loginShoppers());
observer.on('shoppersLoggedIn', () => doShopperActions());
observer.on('upsertionsDone', () => couponsProcessedFired && upsertionsDoneFired ? getRelevantCoupons() : undefined);
observer.on('retailersCreated', () => () => loginRetailers());
observer.on('retailersLoggedIn', () => doRetailerActions());
observer.on('couponsProcessed', () => couponsProcessedFired && upsertionsDoneFired ? getRelevantCoupons() : undefined);

const createCouponIssuerAndCoupons = () => {
    api.createCouponIssuer('123', '123')
    .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
        api.loginCouponIssuer('123')
        .then((o: {token: string, tokenExpiration: string, id: Number}) => {
            // Do logged in stuff here...
            console.log(`couponIssuer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
            coupons.forEach((coupon) => {
                api.postCoupon(coupon, o.token)
                .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
                    console.log('postCoupon complete, response:', res);
                })
                .catch(e => errfn(e));
            });
        })
        .catch(e => errfn(e));
    })
    .catch(e => errfn(e));
}

const retailerTokens = [];
let retailersCreated = 0;
let retailersCreatedFired = false;

const createShoppersAndRetailers = () => {
    for (let i = 1; i <= 10; i++) {
        api.createShopper(`shopper${i}`, `shopper${i}@example.com`, '123', '123')
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            shoppersCreated++
            console.log(`shopper${i} created with response:`, res);
            setTimeout(() => {
                if (shoppersCreated === 10 && !shoppersCreatedFired) {
                    shoppersCreatedFired = true;
                    console.log('All shoppers created!');
                    observer.emit('shoppersCreated');
                }
            }, 1000);
        })
        .catch(e => errfn(e));
        api.createRetailer(`retailer${i}`, `retailer${i}@example.com`, '123', '123')
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            console.log(`retailer${i} created with response:`, res);
            setTimeout(() => {
                if (retailersCreated === 10 && !retailersCreatedFired) {
                    retailersCreatedFired = true;
                    console.log('All retailers created!');
                    observer.emit('retailersCreated');
                }
            }, 1000);
        })
        .catch(e => errfn(e));
    }
};

const loginShoppers = () => {
    for (let i = 1; i <= 10; i++) {
        api.loginShopper(`shopper${i}@example.com`, '123')
        .then((o: {token: string, tokenExpiration: string, id: Number}) => {
            shopperTokens[String(o.id)] = o.token;
            shopperTokensCount++;
            console.log(`shopper${String(o.id)} logged in with token of ${o.token}, tokenExpiration of ${o.tokenExpiration}, and id of ${o.id}`);
            setTimeout(() => {
                if (shopperTokensCount === 10 && !shoppersLoggedInFired) {
                    shoppersLoggedInFired = true;
                    console.log('All shoppers logged in!');
                    observer.emit('shoppersLoggedIn');
                }
            }, 1000);
        })
        .catch(e => errfn(e));
    }
};

const loginRetailers = () => {
    for (let i = 1; i <= 10; i++) {
        api.loginShopper(`retailer${i}@example.com`, '123')
        .then((o: {token: string, tokenExpiration: string, id: Number}) => {
            retailerTokens[String(o.id)] = o.token;
            retailerTokensCount++;
            console.log(`retailer${String(o.id)} logged in with token of ${o.token}, tokenExpiration of ${o.tokenExpiration}, and id of ${o.id}`);
            setTimeout(() => {
                if (retailerTokensCount === 10 && !retailersLoggedInFired) {
                    retailersLoggedInFired = true;
                    console.log('All retailers logged in!');
                    observer.emit('retailersLoggedIn');
                }
            }, 1000);
        })
        .catch(e => errfn(e));
    }
};

let upsertions = 0;
let upsertionsDoneFired = false;

const doShopperActions = () => {
    Object.keys(shopperTokens).forEach((id, idx) => {
        api.upsertShopperPreferences(shopperPrefs(), shopperTokens[id])
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            console.log('upsertShopperPreferences complete, response:', res);
            upsertions++;
            setTimeout(() => {
                if (upsertions === 10 && !upsertionsDoneFired) {
                    upsertionsDoneFired = true;
                    console.log('All upsertions done!');
                    observer.emit('upsertionsDone');
                }
            }, 1000);
        })
        .catch(e => errfn(e));
    })
};

const generateShopperToCoupon: ShopperToCouponRequest = () => {
    const couponID = Math.ceil(Math.random() * 10);
    const isDiscountPercentage = Math.random() < 0.5 ? true : false;
    return {
        shopperID: Math.ceil(Math.random() * 10),
        couponID: couponID,
        isValid: true,
        isRedeemed: false,
        start: new Date.now(),
        end: new Date.now() + 10000,
        progress: 0,
        earningUnit: Math.random() < 0.33 ? 'steps' : Math.random() < 0.5 ? 'purchases' : 'dollars spent',
        earningGoal: Math.ceil(Math.random() * 25),
        name: 'coupon name here',
        title: coupons[couponID].title,
        productDiscountPercentage: isDiscountPercentage ? Math.random() * 85 : -1,
        productDiscount: !isDiscountPercentage ? Math.floor(Math.random() * 4 + 1) * 5 : -1,
        timesProcessed: 0,
    };
};

let couponsProcessed = 0;
let couponsProcessedFired = false;

const doRetailerActions = () => {
    Object.keys(retailerTokens).forEach((id, idx) => {
        api.processCoupon(generateShopperToCoupon(), retailerTokens[id])
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            console.log('processCoupon complete, response:', res);
            upsertions++;
            setTimeout(() => {
                if (couponsProcessed === 10 && !couponsProcessedFired) {
                    couponsProcessedFired = true;
                    console.log('All coupons processed!');
                    observer.emit('couponsProcessed');
                }
            }, 1000);
        })
        .catch(e => errfn(e));
    })
};

// Now we can test HTTP GET with DB query
const getRelevantCoupons = () => {
    Object.keys(shopperTokens).forEach((id, idx) => {
        api.getRelevantCoupons(shopperTokens[id])
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            console.log('getRelevantCoupons response:', res);
        })
        .catch(e => errfn(e));
    })
};

createCouponIssuerAndCoupons();
createShoppersAndRetailers();




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