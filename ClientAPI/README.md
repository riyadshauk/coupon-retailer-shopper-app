This is a client API example, exemplifying how to call the REST API from a couple popular languages: TypeScript and JavaScript.

This API is simply intended to be an example of how to call the REST API and is not necessarily authoritative and not necessarily maintained (or tested!). To understand how to interact with the REST API, directly interacting with and reading the REST API's test cases and codebase in general is the authoritative form of documentation.

To include this as a JavaScript API in your client-side ES6 JavaScript project, simply run:

$ `npm install`

$ `npm run build` to generate `clientAPI.js` directly from `clientAPI.ts`.

Alternatively, to include this as a JavaScript API in your client-side ES5 JavaScript / Node.js project, simply run:
$ `npm install`

$ `npm run build-es5` to generate `clientAPI.js` directly from `clientAPI.ts`.

This client-side API is written in a modular, self-documenting style, so to get started with using it, please have a look through the commented clientAPI.ts/js file.

For example, to call this API from within Node.js, we would do the following:

```bash
$ npm install                                   # make sure you are inside this ClientAPI directory

$ npm run build-es5

> clientapi@1.0.0 build-es5 .../ClientAPI
> (tsc clientAPI.ts --moduleResolution node) || $(./node_modules/typescript/bin/tsc clientAPI.ts --moduleResolution node) && npm run post-build


> clientapi@1.0.0 post-build .../ClientAPI
> sed -i'.bak' '/exports.__esModule/d' clientAPI.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' clientAPI.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' clientAPI.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' clientAPI.js && rm clientAPI.js.bak

$ node                                          # get inside the node REPL
> const apiReq = require('./clientAPI');
undefined
> const api = new apiReq();                     // optionally provide a different backend URL of where the REST API is located.
Successfully instantiated a clientAPI with a back-end REST API endpoint of http://riyadshauk.com:8080/
undefined
> api
ClientAPI {
  createShopper: [Function],
  createRetailer: [Function],
  createCouponIssuer: [Function],
  loginShopper: [Function],
  loginRetailer: [Function],
  loginCouponIssuer: [Function],
  upsertShopperPreferences: [Function],
  updateShopperLocation: [Function],
  getRelevantCoupons: [Function],
  processCoupon: [Function],
  postCoupon: [Function] }
> api.createShopper('riyad', 'ab@c.d', '123', '123');
undefined
> { longitude: 0,
  email: 'ab@c.d',
  name: 'riyad',
  id: 3,
  latitude: 0 }

> // hooray, we've successfully made our first HTTP request using this client-side JavaScript API
```

Example Usage (Quick-start)
===

(Please see populateDB.ts / populateDB.js):

```typescript
// populateDB.ts
import ClientAPI from './clientAPI';
import * as http from 'http';

const hostname = 'localhost'; // or 'riyadshauk.com'
const port = 8080;
const api = new ClientAPI(hostname, port);
api.createShopper('riyad', 'a@b.c', '123', '123', (res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
    // Do stuff after creating shopper here...
    console.log(`Shopper created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
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
});
api.createRetailer('shauk', 'c@b.a', '321', '321', (res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
    // Do stuff after creating retailer here...
    console.log(`Retailer created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginRetailer('c@b.a', '321', (o: {token: string, tokenExpiration: string, id: Number}) => {
        // Do logged in stuff here...
        console.log(`retailer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
    });
});
api.createCouponIssuer('213', '213', (res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
    // Do stuff after creating couponIssuer here...
    console.log(`CouponIssuer created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginCouponIssuer('213', (o: {token: string, tokenExpiration: string, id: Number}) => {
        // Do logged in stuff here...
        console.log(`couponIssuer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
    });
});
```
We can run this example using the following command: `$ npm run build-populateDB-es5 && node populateDB.js`, which gives us the following output:

```bash
$ npm run build-populateDB-es5 && node populateDB.js 

> clientapi@1.0.0 build-populateDB-es5 .../ClientAPI
> (tsc populateDB.ts) || $(./node_modules/typescript/bin/tsc populateDB.ts) ; npm run post-build-populateDB ; npm run post-build

...

> clientapi@1.0.0 post-build-populateDB .../ClientAPI
> sed -i'.bak' '/exports.__esModule/d' populateDB.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' populateDB.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' populateDB.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' populateDB.js && sed -i'.bak' 's/\[\"default\"\]//g' populateDB.js ; rm populateDB.js.bak


> clientapi@1.0.0 post-build .../ClientAPI
> sed -i'.bak' '/exports.__esModule/d' clientAPI.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' clientAPI.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' clientAPI.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' clientAPI.js ; rm clientAPI.js.bak

Successfully instantiated a clientAPI with a back-end REST API endpoint of http://localhost:8080 (Note: using HTTP!)
CouponIssuer created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"30","date":"Mon, 15 Oct 2018 20:39:07 GMT"}, and a body of {"id":1,"name":"CouponIssuer"}
No more data in response.
Retailer created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"39","date":"Mon, 15 Oct 2018 20:39:07 GMT"}, and a body of {"id":1,"name":"shauk","email":"c@b.a"}
No more data in response.
Shopper created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"66","date":"Mon, 15 Oct 2018 20:39:07 GMT"}, and a body of {"email":"a@b.c","id":1,"latitude":0,"name":"riyad","longitude":0}
No more data in response.
couponIssuer with id of 1 is logged in with token of wVIPTCWFn0zN15btlVJLcQ==, set to expire at 2018-10-16T01:39:08Z
No more data in response.
shopper with id of 1 is logged in with token of gQvkTYsD/yD7NsoUgmdKQg==, set to expire at 2018-10-16T01:39:08Z
No more data in response.
Retrieved relevant coupons for shopper with status of 404, and headers of {"content-length":"9","date":"Mon, 15 Oct 2018 20:39:08 GMT"}, and a body of Not found
No more data in response.
retailer with id of 1 is logged in with token of /CB8eyGfRzpl9Ftx+5N8Mg==, set to expire at 2018-10-16T01:39:08Z
No more data in response.
Attempted to update location for shopper with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"70","date":"Mon, 15 Oct 2018 20:39:08 GMT"}, and a body of {"email":"a@b.c","id":1,"latitude":1.5,"name":"riyad","longitude":1.5}
No more data in response.
$ 
```

Client API Reference
===

**Disclaimer: this reference is unstable; please see clientAPI.ts/js, or simply view populateDB.ts/js**


## class ClientAPI  
> **@description** Note: The REST API that this ClientAPI communicates with allows transactions 
from exactly one of the 3 clients: Shopper, Retailer, CouponIssuer.


## constructor  
> **@constructor**  
> **@param** {*string?*} hostname The hostname that represents the back-end REST API endpoint.  
> **@param** {*number?*} port The port of the back-end REST API endpoint.  
> **@param** {*Boolean?*} usingTLS True if using TLS (https), False otherwise (http)


## createShopper  
> **@description** Creates a shopper in the database associated with the REST API.  
> **@param** {*string*} **name**  
> **@param** {*string*} **email**  
> **@param** {*string*} **password**  
> **@param** {*string*} **verifyPassword**  
> **@param** {*({ status: number, headers: string, body: string }) => void*} **\[cb\]** do stuff here that depends on the shopper first being created  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## createRetailer  
> **@description** Creates a retailer in the database associated with the REST API.  
> **@param** {*string*} **name**  
> **@param** {*string*} **email**  
> **@param** {*string*} **password**  
> **@param** {*string*} **verifyPassword**  
> **@param** {*({ status: number, headers: string, body: string }) => void*} **\[cb\]** do stuff here that depends on the retailer first being created  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## createCouponIssuer  
> **@description** Creates a couponIssuer in the database associated with the REST API.  
> **@param** {*string*} **password**  
> **@param** {*string*} **verifyPassword**  
> **@param** {*({ status: number, headers: string, body: string }) => void*} **\[cb\]** do stuff here that depends on the couponIssuer first being created  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## loginShopper  
> **@description** 'Logs' the shopper in by calling the provided callback, cb, with an object with a property named `token`. This token will be needed in order to do things that only a shopper has privileges to do.  
> **@param** {*string*} **username** shopper's email  
> **@param** {*string*} **password** shopper's password  
> **@param** {*({token: string, tokenExpiration: string, id: Number}) => void*} **\[cb\]** a basic authentication token is passed here for client to make authenticated calls (as an authorized shopper) to REST API.  
> **@returns** {*(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)*}


## loginRetailer  
> **@description** 'Logs' the retailer in by calling the provided callback, cb, with an object with a property named `token`. This token will be needed in order to do things that only a retailer has privileges to do.  
> **@param** {*string*} **username** retailer's email  
> **@param** {*string*} **password** retailer's password  
> **@param** {*({token: string, tokenExpiration: string, id: Number}) => void*} **\[cb\]** a basic authentication token is passed here for client to make authenticated calls (as an authorized retailer) to REST API.  
> **@returns** {*(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)*}


## loginCouponIssuer  
> **@description** 'Logs' the couponIssuer in by calling the provided callback, cb, with an object with a property named `token`. This token will be needed in order to do things that only a couponIssuer has privileges to do.  
> **@param** {*string*} **username** couponIssuer's name (should just be "CouponIssuer")  
> **@param** {*string*} **password** couponIssuer's password  
> **@param** {*({token: string, tokenExpiration: string, id: Number}) => void*} **\[cb\]** a basic authentication token is passed here for client to make authenticated calls (as an authorized couponIssuer) to REST API.  
> **@returns** {*(void | Promise<{ token: string, tokenExpiration: string, id: Number }>)*}


## upsertShopperPreferences  
> **@description** Updates (or inserts if not yet in database) the shopper's preferences.  
> **@param** {*ShopperPreferencesRequest*} **shopperPrefs**  
> **@param** {*string*} **token** get this from callback passed to loginShopper  
> **@param** {* status: number, headers: string, body: JSON *} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## updateShopperLocation  
> **@description** Update's a shopper's location. This can only be done by an authorized shopper.  
> **@param** {*UpdateShopperLocationRequest*} **shopperLocation**  
> **@param** {*string*} **token** get this from callback passed to loginShopper  
> **@param** {* status: number, headers: string, body: JSON *} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## getRelevantCoupons  
> **@description** Gets the relevant coupons for a particular shopper. This can only be done by an authorized shopper.  
> **@param** {*string*} **token** get this from callback passed to loginShopper  
> **@param** {* status: number, headers: string, body: JSON *} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## processCoupon  
> **@description** Processes the coupon for a shopper. This can only be done by an authorized retailer. This is meant to signify that a coupon has been processed (by a retailer) during a transaction at a retail store.  
> **@param** {*ShopperToCouponRequest*} **shopperToCoupon**  
> **@param** {*string*} **token** get this from callback passed to loginRetailer  
> **@param** {* status: number, headers: string, body: JSON *} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## postCoupon  
> **@description** Posts a new coupon to the database. This can only be done by an authorized couponIssuer (namely, the backend service that will be creating coupons on behalf of each participating retailer, based on a set of criteria that each retailer will need to provide).  
> **@param** {*CreateCouponRequest*} **createCouponRequest**   
> **@param** {*string*} **token** get this from callback passed to loginCouponIssuer  
> **@param** {* status: number, headers: string, body: JSON *} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}