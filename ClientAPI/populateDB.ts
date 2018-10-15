import ClientAPI from './clientAPI';
import * as http from 'http';

const hostname = 'localhost'; // or 'riyadshauk.com'
const port = 8080;
const api = new ClientAPI(hostname, port);
api.createShopper('riyad', 'a@b.c', '123', '123');
api.createRetailer('shauk', 'c@b.a', '321', '321');
api.createCouponIssuer('213', '213');
api.loginShopper('a@b.c', '123', (o: {token: string, tokenExpiration: string, id: Number}) => {
    // Do logged in stuff here...
    console.log(`shopper with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
    api.getRelevantCoupons(o.token, (res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
        console.log(`Retrieved relevant coupons for shopper with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
        // console.log('res.headers:', res.headers);
    });
    const newLoc = { latitude: 1.5, longitude: 1.5 };
    api.updateShopperLocation(newLoc, o.token, (res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
        console.log(`Attempted to update location for shopper with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
        // console.log('res.headers:', res.headers);
    });
});
api.loginRetailer('c@b.a', '321', (o: {token: string, tokenExpiration: string, id: Number}) => {
    // Do logged in stuff here...
    console.log(`retailer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
});
api.loginCouponIssuer('213', (o: {token: string, tokenExpiration: string, id: Number}) => {
    // Do logged in stuff here...
    console.log(`couponIssuer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
});