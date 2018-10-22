Brief Description
===

This project consists of an authenticated REST API + DB (written in Swift 4 + Vapor, can build on both Linux and macOS), which also contains a ClientAPI/db_scripts/populator.ts to populate the database associated with this REST API via a client-side JavaScript wrapper API.

This project also consists of two client-side applications (both written in Swift 4): A Retailer app, RetailerQRReader, and a Shopper app, ShopperQRCodeCouponClient.

I made these for a demo POC project. The two iOS applications were initially just hacked together over 2-3 days, so I didn't spend nearly as much time on code quality and design as I did on the authenticated REST API + DB I built.

Project Notes (Getting Situated with the Project Structure)
===

For the iPhone apps built in Swift 4, after cloning this repo, you will just need to open their corresponding .xcodeproj files to launch each app's Xcode project. Also, in case you have difficulty navigating to [the Retailer app, here's its location in the project](https://github.com/riyadshauk/coupon-retailer-shopper-app/tree/master/RetailerQRReader/Example/QRCodeReader.swift).


Building and Running the webserver & demo apps
===

Note that in order to run these apps, you will need to modify the URL of the webserver to wherever you run your webserver (which will probably be localhost:8080). However, connecting to an iPhone app on localhost:8080 doesn't really work too well. For that, a simple solution is to download the [Ngrok tool](https://ngrok.com/), then run `ngrok http 8080` in your terminal, for example; this will open up your localhost webserver running on port 8080 at a specified temporary ngrok URL (with an 8 hour lifetime). Use that URL (outputted in your Terminal) as the webserver URL used in the Retailer and Shopper client apps (search for `http` or `ngrok` to find those locations, and do a simple find-replace).

Then just Run the Xcode project as you normally would. Go ahead and follow [these directions for how to test an iPhone app on a real device using Xcode](https://www.twilio.com/blog/2018/07/how-to-test-your-ios-application-on-a-real-device.html), or something similar, for more info.