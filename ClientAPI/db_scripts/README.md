## Populater Script

**Disclaimer: This is a WIP. Still adding features / fixing bugs.**
@todo: Correctly create ShopperToCoupon entries, and correctly GET relevantCoupons for any given shopper.

To transpile and run this database populater script:

```bash
$ npm install -g typescript
$ npm start
```

Also, be sure to first edit the hostname in populater.ts, and make sure that the back-end webserver is running on the host machine. Refer to the [WebServer]("https://github.com/riyadshauk/coupon-retailer-shopper-webserver") README for more info.

Also note that this script was only tested on macOS, so if you run into trouble running it on Linux, you may need to modify the usage of the `sed` command in `package.json` accordingly, or manually remove the lines requiring interface files at the top of the generated ClientAPI.js, eg.