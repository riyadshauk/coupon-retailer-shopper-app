import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // public routes
    
    // userController code here just to test out functionality...
    let userController = UserController()
    router.post("users", use: userController.create)
    let basicUser = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basicUser.post("userLogin", use: userController.login)
    
    let shopperController = ShopperController()
    router.post("shopper", use: shopperController.create)
    
    let retailerController = RetailerController()
    router.post("retailer", use: retailerController.create)
    
    let couponIssuerController = CouponIssuerController() // There shall only be one coupon issuer; namely our backend coupon-issuing service
    router.post("couponIssuer", use: couponIssuerController.create)
    
    // basic / password auth protected routes

    let basicShopper = router.grouped(Shopper.basicAuthMiddleware(using: BCryptDigest()))
    basicShopper.post("shopperLogin", use: shopperController.login)
    
    let basicRetailer = router.grouped(Retailer.basicAuthMiddleware(using: BCryptDigest()))
    basicRetailer.post("retailerLogin", use: retailerController.login)
    
    let basicCouponIssuer = router.grouped(CouponIssuer.basicAuthMiddleware(using: BCryptDigest()))
    basicCouponIssuer.post("couponIssuerLogin", use: couponIssuerController.login)
    
    
    // bearer / token auth protected routes
    let bearerShopper = router.grouped(Shopper.tokenAuthMiddleware())
    let bearerRetailer = router.grouped(Retailer.tokenAuthMiddleware())
    let bearerCouponIssuer = router.grouped(CouponIssuer.tokenAuthMiddleware())
    
    bearerShopper.post("preferences", use: shopperController.upsertPreferences)
    bearerShopper.post("location", use: shopperController.updateCurrentLocation)
    bearerShopper.get("relevantCoupons", use: shopperController.getRelevantCoupons)
    
    bearerRetailer.post("processCoupon", use: retailerController.processCoupon)
    
    bearerCouponIssuer.post("relevantCoupon", use: couponIssuerController.postCoupon)
}
