import ClientAPI from './clientAPI';
const hostname = 'localhost'; // or 'riyadshauk.com'
const port = 8080;
const api = new ClientAPI(hostname, port);
api.createShopper('riyad', 'a@b.c', '123', '123', (res) => {
    // Do stuff after creating shopper here...
    console.log(`Shopper created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginShopper('a@b.c', '123', (o) => {
        // Do logged in stuff here...
        console.log(`shopper with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
        api.getRelevantCoupons(o.token, (res) => {
            console.log(`Retrieved relevant coupons for shopper with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
        });
        const newLoc = { latitude: 1.5, longitude: 1.5 };
        api.updateShopperLocation(newLoc, o.token, (res) => {
            console.log(`Attempted to update location for shopper with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
        });
    });
});
api.createRetailer('shauk', 'c@b.a', '321', '321', (res) => {
    // Do stuff after creating retailer here...
    console.log(`Retailer created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginRetailer('c@b.a', '321', (o) => {
        // Do logged in stuff here...
        console.log(`retailer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
    });
});
api.createCouponIssuer('213', '213', (res) => {
    // Do stuff after creating couponIssuer here...
    console.log(`CouponIssuer created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginCouponIssuer('213', (o) => {
        // Do logged in stuff here...
        console.log(`couponIssuer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
    });
});
