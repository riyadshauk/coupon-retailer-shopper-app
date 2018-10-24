<p align="center">
    <a href="https://nodejs.org/api/esm.html">
        <img src="AuthenticatedAPIBackend/ClientAPI/misc/node%40current-_%3D10.12.0-brightgreen.svg" alt="Node 10.12.0">
    </a>
</p>

ClientAPI
===

This is a client API example, exemplifying how to call the REST API from a couple popular languages: TypeScript and JavaScript.

This API is simply intended to be an example of how to call the REST API and is not necessarily authoritative and not necessarily maintained (or tested!). To understand how to interact with the REST API, directly interacting with and reading the REST API's test cases and codebase in general is the authoritative form of documentation.

Table of contents
=================

<!--ts-->
   * [ClientAPI](#clientapi)
   * [Table of contents](#table-of-contents)
   * [Overview](#overview)
   * [Setup](#setup)
   * [Using the Node REPL (CLI)](#using-the-node-repl-cli)
   * [Example Usage (Quick-start)](#example-usage-quick-start)
      * [Using Callbacks](#using-callbacks)
      * [Using Promises](#using-promises)
   * [Client API Reference](#client-api-reference)
      * [class ClientAPI](#class-clientapi)
      * [constructor](#constructor)
      * [createShopper](#createshopper)
      * [createRetailer](#createRetailer)
      * [createCouponIssuer](#createcouponissuer)
      * [loginShopper](#loginshopper)
      * [loginRetailer](#loginretailer)
      * [loginCouponIssuer](#logincouponissuer)
      * [upsertShopperPreferences](#upsertshopperpreferences)
      * [updateShopperLocation](#updateshopperlocation)
      * [getRelevantCoupons](#getrelevantcoupons)
      * [processCoupon](#processcoupon)
      * [postCoupon](#postcoupon)
      * [assignShopperToCoupon](#assignShopperToCoupon)
    * [Contributing](#contributing)
<!--te-->

Setup
---

To include this as a JavaScript API in your client-side ES6 JavaScript project, simply run:

**Note: this repo comes with only TypeScript (which is simply a superset of JavaScript with strong typing) source files, by default, but you can still generate ES5 JavaScript, as shown below**

$ `npm install`

$ `npm run build` to generate `clientAPI.js` directly from `clientAPI.ts`.

Alternatively, to include this as a JavaScript API in your client-side ES5 JavaScript / Node.js project, simply run:
$ `npm install`

$ `npm run build-es5` to generate `clientAPI.js` directly from `clientAPI.ts`.

This client-side API is written in a modular, self-documenting style, so to get started with using it, please have a look through the commented clientAPI.ts/js file.

Using the Node REPL (CLI)
---

For example, to call this API from within Node.js, we would do the following:

```bash
$ npm install                                           # make sure you are inside this ClientAPI directory

$ npm run build-es5

> clientapi@1.0.0 build-es5 \{full path omitted\}/ClientAPI
> (tsc clientAPI.ts) || $(./node_modules/typescript/bin/tsc clientAPI.ts) ; npm run post-build

\{TS errors omitted...\}

> clientapi@1.0.0 post-build \{full path omitted\}/ClientAPI
> sed -i'.bak' '/exports.__esModule/d' clientAPI.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' clientAPI.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' clientAPI.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' clientAPI.js ; rm clientAPI.js.bak

$ node                                                  # get inside the node REPL
> const ClientAPI = require('./clientAPI');
undefined
> const api = new ClientAPI('localhost', 8080);         // optionally provide a different backend URL of where the REST API is located
Successfully instantiated a clientAPI with a back-end REST API endpoint of http://localhost:8080 (Note: using HTTP!)
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
  processCoupon: [processCoupon],
  postCoupon: [Function],
  assignShopperToCoupon: [Function],
  apiHelpers:
   { baseUrl: 'http://localhost:8080',
     hostname: 'localhost',
     port: 8080,
     routes:
      { createShopper: '/shopper',
        createRetailer: '/retailer',
        createCouponIssuer: '/couponIssuer',
        loginShopper: '/shopperLogin',
        loginRetailer: '/retailerLogin',
        loginCouponIssuer: '/couponIssuerLogin',
        upsertShopperPreferences: '/preferences',
        updateShopperLocation: '/location',
        getRelevantCoupons: '/relevantCoupons',
        processCoupon: '/processCoupon',
        postCoupon: '/relevantCoupon'
        assignShopperToCoupon: '/assignShopperToCoupon' },
     postWithOptions: [Function: postWithOptions],
     createUser: [Function: createUser],
     createCouponIssuer: [Function: createCouponIssuer],
     loginUser: [Function: loginUser],
     loginCouponIssuer: [Function: loginCouponIssuer],
     postWithAuthentication: [Function: postWithAuthentication] } }
> api.createShopper('riyad', 'a@b.c', '123', '123', function (res) {
...     // Do stuff after creating shopper here...
...     console.log("Shopper created with status of " + String(res.status) + ", and headers of " + JSON.stringify(res.headers) + ", and a body of " + res.body);
...     api.loginShopper('a@b.c', '123', function (o) {
.....         // Do logged in stuff here...
.....     });
... });
undefined
> Shopper created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"66","date":"Wed, 17 Oct 2018 01:53:09 GMT"}, and a body of {"email":"a@b.c","id":1,"latitude":0,"name":"riyad","longitude":0}
No more data in response.
No more data in response.

> // hooray, we've successfully made our first HTTP request using this client-side JavaScript API
```

Example Usage (Quick-start)
===

**Note: Please refer to [db_scripts](https://github.com/riyadshauk/coupon-retailer-shopper-webserver/tree/master/ClientAPI/db_scripts) for a complete [populator.ts](https://github.com/riyadshauk/coupon-retailer-shopper-webserver/tree/master/ClientAPI/db_scripts/populator.ts) script to get you up and running with integrating data in your front- or back-end services.** *The README on that page is designed to get you hacking along in no time!*

Using Callbacks
---

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
$ npm run build1 && npm run pop

> clientapi@1.0.0 build1 \{full path omitted\}/ClientAPI
> npm run build-populateDB && npm run build


> clientapi@1.0.0 build-populateDB \{full path omitted\}/ClientAPI
> (tsc populateDB.ts --target es6) || $(./node_modules/typescript/bin/tsc populateDB.ts --target es6) ; npm run post-build-populateDB && cp populateDB.js populateDB.mjs

clientAPI.ts:64:70 - error TS2345: Argument of type '(res: { status: number; headers: IncomingHttpHeaders; body: string; }) => void' is not assignable to parameter of type '{ status: number; headers: IncomingHttpHeaders; body: string; }'.
  Property 'status' is missing in type '(res: { status: number; headers: IncomingHttpHeaders; body: string; }) => void'.

\{TS errors omitted...\}

> clientapi@1.0.0 post-build-populateDB \{full path omitted\}/ClientAPI
> sed -i'.bak' '/exports.__esModule/d' populateDB.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' populateDB.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' populateDB.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' populateDB.js && sed -i'.bak' 's/\[\"default\"\]//g' populateDB.js ; rm populateDB.js.bak


> clientapi@1.0.0 build \{full path omitted\}/ClientAPI
> (tsc clientAPI.ts --target es6) || $(./node_modules/typescript/bin/tsc clientAPI.ts --target es6) ; npm run post-build && cp clientAPI.js clientAPI.mjs

\{TS errors omitted...\}

> clientapi@1.0.0 post-build \{full path omitted\}/ClientAPI
> sed -i'.bak' '/exports.__esModule/d' clientAPI.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' clientAPI.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' clientAPI.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' clientAPI.js ; rm clientAPI.js.bak


> clientapi@1.0.0 pop \{full path omitted\}/ClientAPI
> node --experimental-modules populateDB.mjs

(node:16930) ExperimentalWarning: The ESM module loader is experimental.
Successfully instantiated a clientAPI with a back-end REST API endpoint of http://localhost:8080 (Note: using HTTP!)
Retailer created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"39","date":"Wed, 17 Oct 2018 00:07:05 GMT"}, and a body of {"id":1,"name":"shauk","email":"c@b.a"}
No more data in response.
CouponIssuer created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"30","date":"Wed, 17 Oct 2018 00:07:05 GMT"}, and a body of {"id":1,"name":"CouponIssuer"}
No more data in response.
Shopper created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"66","date":"Wed, 17 Oct 2018 00:07:05 GMT"}, and a body of {"email":"a@b.c","id":1,"latitude":0,"name":"riyad","longitude":0}
No more data in response.
couponIssuer with id of 1 is logged in with token of PN5UgUOty2CcCfuD1UfCnw==, set to expire at 2018-10-17T05:07:06Z
No more data in response.
shopper with id of 1 is logged in with token of 2zkew2015/2P9uNSNjFIqA==, set to expire at 2018-10-17T05:07:06Z
No more data in response.
retailer with id of 1 is logged in with token of X7AWyMTTZZUKtUxyjHuxAQ==, set to expire at 2018-10-17T05:07:06Z
No more data in response.
Retrieved relevant coupons for shopper with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"2","date":"Thu, 18 Oct 2018 07:28:28 GMT"}, and a body of []
No more data in response.
Attempted to update location for shopper with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"70","date":"Wed, 17 Oct 2018 00:07:06 GMT"}, and a body of {"email":"a@b.c","id":1,"latitude":1.5,"name":"riyad","longitude":1.5}
No more data in response.
$
```

Using Promises
---

```typescript
// populateDB_usingPromises.ts
import ClientAPI from './clientAPI';
import * as http from 'http';

const errfn = (err) => console.error(`Promise ERROR: ${err}`);

const hostname = 'localhost';
const port = 8080;
const api = new ClientAPI(hostname, port);
api.createShopper('riyad', 'a@b.c', '123', '123')
.then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
    // Do stuff after creating shopper here...
    console.log(`Shopper created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginShopper('a@b.c', '123')
    .then((o: {token: string, tokenExpiration: string, id: Number}) => {
        // Do logged in stuff here...
        console.log(`shopper with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
        api.getRelevantCoupons(o.token)
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            console.log(`Retrieved relevant coupons for shopper with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
        })
        const newLoc = { latitude: 1.5, longitude: 1.5 };
        api.updateShopperLocation(newLoc, o.token)
        .then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
            console.log(`Attempted to update location for shopper with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
        })
        .catch((err) => errfn(err));
    })
})
.catch((err) => errfn(err));
api.createRetailer('riyad', 'a@b.c', '123', '123')
.then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
    // Do stuff after creating retailer here...
    console.log(`Retailer created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginRetailer('a@b.c', '123')
    .then((o: {token: string, tokenExpiration: string, id: Number}) => {
        // Do logged in stuff here...
        console.log(`retailer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
    })
    .catch((err) => errfn(err));
})
.catch((err) => errfn(err));
api.createCouponIssuer('123', '123')
.then((res: { status: number, headers: http.IncomingHttpHeaders, body: string }) => {
    // Do stuff after creating couponIssuer here...
    console.log(`CouponIssuer created with status of ${String(res.status)}, and headers of ${JSON.stringify(res.headers)}, and a body of ${res.body}`);
    api.loginCouponIssuer('123')
    .then((o: {token: string, tokenExpiration: string, id: Number}) => {
        // Do logged in stuff here...
        console.log(`couponIssuer with id of ${o.id} is logged in with token of ${o.token}, set to expire at ${o.tokenExpiration}`);
    })
    .catch((err) => errfn(err));
})
.catch((err) => errfn(err));
```

We can run this example using the following command: `$ npm run build1 && npm run popPromises`, which gives us the following output:

```bash
$ npm run build1 && npm run popPromises

> clientapi@1.0.0 build1 \{full path omitted\}/ClientAPI
> npm run build-populateDB && npm run build && npm run examplePromises


> clientapi@1.0.0 build-populateDB \{full path omitted\}/ClientAPI
> (tsc populateDB.ts --target es6) || $(./node_modules/typescript/bin/tsc populateDB.ts --target es6) ; npm run post-build-populateDB && cp populateDB.js populateDB.mjs

\{TS errors omitted...\}

> clientapi@1.0.0 post-build-populateDB \{full path omitted\}/ClientAPI
> sed -i'.bak' '/exports.__esModule/d' populateDB.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' populateDB.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' populateDB.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' populateDB.js && sed -i'.bak' 's/\[\"default\"\]//g' populateDB.js ; rm populateDB.js.bak


> clientapi@1.0.0 build \{full path omitted\}/ClientAPI
> (tsc clientAPI.ts --target es6) || $(./node_modules/typescript/bin/tsc clientAPI.ts --target es6) ; npm run post-build && cp clientAPI.js clientAPI.mjs

\{TS errors omitted...\}

> clientapi@1.0.0 post-build \{full path omitted\}/ClientAPI
> sed -i'.bak' '/exports.__esModule/d' clientAPI.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' clientAPI.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' clientAPI.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' clientAPI.js ; rm clientAPI.js.bak


> clientapi@1.0.0 examplePromises \{full path omitted\}/ClientAPI
> (tsc populateDB_usingPromises.ts --target es6) || $(./node_modules/typescript/bin/tsc populateDB_usingPromises.ts --target es6) ; npm run post-build-examplePromises ; npm run post-build

\{TS errors omitted...\}

> clientapi@1.0.0 post-build-examplePromises \{full path omitted\}/ClientAPI
> sed -i'.bak' '/exports.__esModule/d' populateDB_usingPromises.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' populateDB_usingPromises.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' populateDB_usingPromises.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' populateDB_usingPromises.js && sed -i'.bak' 's/\[\"default\"\]//g' populateDB_usingPromises.js ; rm populateDB_usingPromises.js.bak && cp populateDB_usingPromises.js populateDB_usingPromises.mjs


> clientapi@1.0.0 post-build \{full path omitted\}/ClientAPI
> sed -i'.bak' '/exports.__esModule/d' clientAPI.js && sed -i'.bak' 's/exports\[\"default\"\]/module.exports/g' clientAPI.js && sed -i'.bak' -e '/require\(.*interfaces\/.*\)/d' clientAPI.js && sed -i'.bak' -e '/import.*interfaces\/.*/d' clientAPI.js ; rm clientAPI.js.bak


> clientapi@1.0.0 popPromises \{full path omitted\}/ClientAPI
> node --experimental-modules populateDB_usingPromises.mjs

(node:24512) ExperimentalWarning: The ESM module loader is experimental.
Successfully instantiated a clientAPI with a back-end REST API endpoint of http://localhost:8080 (Note: using HTTP!)
No more data in response.
CouponIssuer created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"30","date":"Wed, 17 Oct 2018 01:38:26 GMT"}, and a body of {"id":1,"name":"CouponIssuer"}
No more data in response.
Retailer created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"39","date":"Wed, 17 Oct 2018 01:38:26 GMT"}, and a body of {"id":1,"name":"riyad","email":"a@b.c"}
No more data in response.
Shopper created with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"66","date":"Wed, 17 Oct 2018 01:38:26 GMT"}, and a body of {"email":"a@b.c","id":1,"latitude":0,"name":"riyad","longitude":0}
No more data in response.
retailer with id of 1 is logged in with token of GtZN6jFDU+e0uj4udlMpdQ==, set to expire at 2018-10-17T06:38:26Z
No more data in response.
couponIssuer with id of 1 is logged in with token of 61WuKAm957hmRjGRtGnU4g==, set to expire at 2018-10-17T06:38:26Z
No more data in response.
shopper with id of 1 is logged in with token of WhSlE04FSre/UYZzNDRAQQ==, set to expire at 2018-10-17T06:38:27Z
No more data in response.
Retrieved relevant coupons for shopper with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"2","date":"Thu, 18 Oct 2018 07:28:28 GMT"}, and a body of []
No more data in response.
Attempted to update location for shopper with status of 200, and headers of {"content-type":"application/json; charset=utf-8","content-length":"70","date":"Wed, 17 Oct 2018 01:38:27 GMT"}, and a body of {"email":"a@b.c","id":1,"latitude":1.5,"name":"riyad","longitude":1.5}
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
> **@param** {*status: number, headers: string, body: JSON*} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## updateShopperLocation  
> **@description** Update's a shopper's location. This can only be done by an authorized shopper.  
> **@param** {*UpdateShopperLocationRequest*} **shopperLocation**  
> **@param** {*string*} **token** get this from callback passed to loginShopper  
> **@param** {*status: number, headers: string, body: JSON*} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## getRelevantCoupons  
> **@description** Gets the relevant coupons for a particular shopper. This can only be done by an authorized shopper.  
> **@param** {*string*} **token** get this from callback passed to loginShopper  
> **@param** {*status: number, headers: string, body: JSON*} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}


## processCoupon  
> **@description** Processes the coupon for a shopper. This can only be done by an authorized retailer. This is meant to signify that a coupon has been processed (by a retailer) during a transaction at a retail store.  
> **@param** {*ProcessCouponRequest*} **processCouponRequest**  
> **@param** {*string*} **token** get this from callback passed to loginRetailer  
> **@param** {*status: number, headers: string, body: JSON*} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}

## postCoupon  
> **@description** Posts a new coupon to the database. This can only be done by an authorized couponIssuer (namely, the backend service that will be creating coupons on behalf of each participating retailer, based on a set of criteria that each retailer will need to provide).  
> **@param** {*CreateCouponRequest*} **createCouponRequest**   
> **@param** {*string*} **token** get this from callback passed to loginCouponIssuer  
> **@param** {*status: number, headers: string, body: JSON*} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}

## assignShopperToCoupon  
> **@description** Assigns a shopper to a coupon. This can only be done by the authorized couponIssuer.  
> **@param** {*ShopperToCouponRequest*} **shopperToCoupon**  
> **@param** {*string*} **token** get this from callback passed to loginCouponIssuer  
> **@param** {*status: number, headers: string, body: JSON*} **\[cb\]** sends back response and possibly relevant body to client from REST API  
> **@returns** {*(void | Promise<{ status: number, headers: http.IncomingHttpHeaders, body: string }>)*}

Contributing
===
**Please be sure to run `$ cd db_scripts && npm test` and see no errors before committing any changes to this codebase : )**