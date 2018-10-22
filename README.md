This project consists of an authenticated REST API + DB (written in Swift 4 + Vapor, can build on both Linux and macOS), which also contains a ClientAPI/db_scripts/populator.ts to populate the database associated with this REST API via a client-side JavaScript wrapper API.

This project also consists of two client-side applications (both written in Swift 4): RetailerQRReader and ShopperQRCodeCouponClient.

I made these for a demo POC project. The two iOS applications were initially just hacked together over 2-3 days, so I didn't spend nearly as much time on code quality and design as I did on the authenticated REST API + DB I built.