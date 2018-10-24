Coupon-Retailer-Shopper App
===

Clone Me!
===
```bash
$ git clone https://github.com/riyadshauk/coupon-retailer-shopper-app.git
$ cd coupon-retailer-shopper-app/Eureka
$ git init submodules
```

What'd we just do?
---
I've used two 3rd-party libraries when building the mobile apps (a [QR Code reading library](https://github.com/yannickl/QRCodeReader.swift), and [form-creating library, Eureka](https://github.com/xmartlabs/Eureka) – to easily write a clean login form). To get Eureka working properly for this project, we utilize [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), as shown above. Alternatively, Cocoa Pods or Carthage could have been used.

Table of contents
=================

<!--ts-->
   * [ClientAPI](#coupon-retailer-shopper-app)
   * [Setup](#clone-me)
      * [What'd we just do?](#whatd-we-just-do)
   * [Table of contents](#table-of-contents)
   * [Brief Description](#brief-description)
      * [Actual Demo Functionality](#actual-demo-functionality)
   * [Project Notes (Getting Situated with the Project Structure)](#project-notes-getting-situated-with-the-project-structure))
   * [Building and Running the webserver & demo apps](#building-and-running-the-webserver--demo-apps)
<!--te-->

Brief Description
===

This project consists of an authenticated REST API + DB (written in Swift 4 + Vapor, can build on both Linux and macOS), which also contains a ClientAPI/db_scripts/populator.ts to populate the database associated with this REST API via a client-side JavaScript wrapper API.

This project also consists of two client-side applications (both written in Swift 4): A Retailer app, RetailerQRReader, and a Shopper app, ShopperQRCodeCouponClient.

I made these for a demo POC project. The two iOS applications were initially just hacked together over a couple days, so I didn't spend nearly as much time on code quality and design as I did on the authenticated REST API + DB I built.

Actual Demo Functionality
---
1. Shopper/Retailer login with basic authentication (assume account already created)
2. Shopper screen contains QR codes representing relevant coupons for him (assume he already saved his preferences)
3. Retailer scans a QR code displayed on the Shopper app and POSTs the coupon info to the backend using a bearer token (supplied on login)
4. Shopper GETs relevant coupons using bearer token (supplied on login)
5. When Shopper logs out and logs back in, he will see that a `timesProcessed` variable associated with the coupon that was scanned has increased by one
  * *Not Fully Implemented:* In practice, another backend, possibly part of some larger system, would POST relevant coupons to the database based on a set of rules which would be initialized, in part, from the Retailer. These would be sent to the Shopper when he polls for relevant coupons.

Project Notes (Getting Situated with the Project Structure)
===

For the iPhone apps built in Swift 4, after cloning this repo, you will just need to open their corresponding .xcodeproj files to launch each app's Xcode project. Also, in case you have difficulty navigating to [the Retailer app, here's its location in the project](https://github.com/riyadshauk/coupon-retailer-shopper-app/tree/master/RetailerQRReader/Example/QRCodeReader.swift).

Building and Running the webserver & demo apps
===

Note that in order to run these apps, you will need to modify the URL of the webserver to wherever you run your webserver (which will probably be localhost:8080). However, connecting to an iPhone app on localhost:8080 doesn't really work too well. For that, a simple solution is to download the [Ngrok tool](https://ngrok.com/), then run `ngrok http 8080` in your terminal, for example; this will open up your localhost webserver running on port 8080 at a specified temporary ngrok URL (with an 8 hour lifetime). Use that URL (outputted in your Terminal) as the webserver URL used in the Retailer and Shopper client apps (search for `http` or `ngrok` to find those locations, and do a simple find-replace).

Then just Run the Xcode project as you normally would. Go ahead and follow [these directions for how to test an iPhone app on a real device using Xcode](https://www.twilio.com/blog/2018/07/how-to-test-your-ios-application-on-a-real-device.html), or something similar, for more info.