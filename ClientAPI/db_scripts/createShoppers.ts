import ClientAPI from '../clientAPI';
import * as http from 'http';
import { EventEmitter } from 'events'; // see: https://nodejs.org/dist/latest-v10.x/docs/api/events.html
import coupons from './coupons';
import shopperPrefs from './shopperPrefs';

const hostname = 'localhost';
const port = 8080;
const api = new ClientAPI(hostname, port);

let shoppersCreated = 0;
const shopperTokens = {};
shopperTokensCount = 0;

const errfn = (err) => console.error(`Promise ERROR: ${err}`);

class Observer extends EventEmitter {};
const observer = new Observer();
observer.on('shoppersCreated', () => loginShoppers());
observer.on('shoppersLoggedIn', () => doShopperActions());
createCouponIssuerAndCoupons();
createShoppersAndRetailers();

const createCouponIssuerAndCoupons = () => {
    api.createCouponIssuer('123', '123')
    .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
        api.loginCouponIssuer('123')
        .then((o: {token: string, tokenExpiration: string, id: Number}) => {
            // Do logged in stuff here...
            console.log(`couponIssuer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
            coupons.forEach((coupon) => {

            });
        })
        .catch((err) => errfn(err));
    })
    .catch((err) => errfn(err));
}

const createUsers = () => {
    for (let i = 1; i <= 10; i++) {
        api.createShopper(`shopper${i}`, `shopper${i}@example.com`, '123', '123')
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            shoppersCreated++
            if (shoppersCreated === 10) {
                observer.emit('shoppersCreated');
            }
        })
        .catch((e) => errfn(e));
        api.createRetailer(`retailer${i}`, `retailer${i}@example.com`, '123', '123');
    }
};

const loginShoppers = () => {
    for (let i = 1; i <= 10; i++) {
        api.loginShopper(`shopper${i}`, '123')
        .then((o: {token: string, tokenExpiration: string, id: Number}) => {
            shopperTokens[String(id)] = token;
            shopperTokensCount++;
            if (shopperTokensCount === 10) {
                observer.emit('shoppersLoggedIn');
            }
        })
        .catch((e) => errfn(e));
    }
};

const doShopperActions = () => {
    shopperTokens.forEach((token, idx) => {
        api.upsertShopperPreferences(shopperPrefs[idx], token);
    })
};