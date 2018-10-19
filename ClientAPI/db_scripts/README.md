## Populator Script

**Disclaimer: If you want to modify this script, do so at your own peril; it hasn't been tested on callbacks (only supports Promises, as shown in the snippet below).**

To transpile and run this database populater script:

```bash
$ npm install -g typescript
$ npm start
```

Also, be sure to first edit the hostname in `populator.ts`, and make sure that the back-end webserver is running on the host machine. Refer to the [WebServer]("https://github.com/riyadshauk/coupon-retailer-shopper-webserver") README for more info.

Also note that this script was only tested on macOS, so if you run into trouble running it on Linux, you may need to modify the usage of the `sed` command in `package.json` accordingly, or manually remove the lines requiring interface files at the top of the generated ClientAPI.js, eg.

In case you're interested, this is how simple it is to automate populating the DB (taken from the very bottom of `populator.ts`):

```javascript
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
```