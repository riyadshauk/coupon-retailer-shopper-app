interface ShopperPreferencesRequest {
    /// Reference to shopper that owns this ShopperPreferences.
    // shopperID: Number; /* Get this from the callback passed to loginShopper */
    
    // various shopper preferences...
    jeans: Boolean;
    shirts: Boolean;
    longsleeve: Boolean;
    shortsleeve: Boolean;
    computers: Boolean;
    videogames: Boolean;
    sports: Boolean;
}

interface UpdateShopperLocationRequest {
    latitude: Number;
    longitude: Number;
}

interface ShopperToCouponRequest {
    /// Reference to Shopper that belongs to this ShopperToCoupon.
    shopperID: Number;
    /// Reference to Coupon that belongs to this ShopperToCoupon.
    couponID: Number;
    start: Date;
    end: Date;
    // progress = some multiple of earningUnit divided by earningGoal
    progress: Number;
    // ie: "steps"
    earningUnit: String;
    // ie: 100 (for 100 steps)
    earningGoal: Number;
    isValid: Boolean;
    // initially must be initialized to false
    isRedeemed: Boolean;
    product: String;
    name: String;
    title: String;
    // if productDiscountPercentage < 0, it's invalid
    productDiscountPercentage: Number;
    // if productDiscount < 0, it's invalid
    productDiscount: Number;
    timesProcessed: Number;
}

interface CreateCouponRequest {
    title: String;
    /// Reference to Retailer that owns this Coupon.
    retailerID: Number;
}