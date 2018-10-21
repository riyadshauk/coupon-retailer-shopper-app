<p align="center">
    <a href="https://nodejs.org/api/esm.html">
        <img src="https://github.com/riyadshauk/coupon-retailer-shopper-webserver/blob/master/ClientAPI/misc/node@current-_=10.12.0-brightgreen.svg" alt="Node 10.12.0">
    </a>
</p>

## Populator Script

**Disclaimer: If you want to modify this script, do so at your own peril; it hasn't been tested on callbacks (only supports Promises, as shown in the snippet below).**

To transpile and run this database populater script:

```bash
$ npm install
$ npm start
```

Also, be sure to first edit the hostname in `populator.ts`, and make sure that the back-end webserver is running on the host machine. Refer to the [WebServer]("https://github.com/riyadshauk/coupon-retailer-shopper-webserver") README for more info.

Also note that this script was only tested on macOS, so if you run into trouble running it on Linux, you may need to modify the usage of the `sed` command in `package.json` accordingly, or manually remove the lines requiring interface files at the top of the generated ClientAPI.js, eg.

In case you're interested, this is how simple it is to automate populating the DB (taken from the very bottom of `populator.ts`):

```javascript
/**
 * Actually execute the API queries to populate the Database here
 */
createUser(SHOPPER, 10)
.then(() => loginUser(SHOPPER, 10))
.then((shopperTokens) => {
    doShopperActions(shopperTokens)
    .catch((e) => errfn(e));

    createUser(RETAILER, 10)
    .then(() => loginUser(RETAILER, 10))
        
    .then(() => createUser(COUPONISSUER))
    .then(() => loginUser(COUPONISSUER))
    .then((couponIssuerToken) => {
        postCoupons(couponIssuerToken)
        .then(() => doCouponIssuerActions(couponIssuerToken))
    })
    .then(() => getRelevantCoupons(shopperTokens))
    .catch((e) => errfn(e));
})
.catch((e) => errfn(e));
```

## Contributing
**Please be sure to run `$ npm test` and see no errors before committing any changes to this codebase : )**