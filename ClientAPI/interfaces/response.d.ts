// This file is just for reference/documentation into the REST API.
// This is not an authoritative file, and it is not necessarily maintained.
// Best practice is to look at the REST API.

/// Public representation of shopper data.
class ShopperResponse {
    /// Shopper's unique identifier.
    /// Not optional since we only return shoppers that exist in the DB.
    id: Number;
    
    /// Shopper's full name.
    name: String;
    
    /// Shopper's email address.
    email: String;
    
    latitude: Number;
    
    longitude: Number;
}

class ShopperPreferencesResponse {
    id: Number;
    jeans: Boolean;
    shirts: Boolean;
    longsleeve: Boolean;
    shortsleeve: Boolean;
    computers: Boolean;
    videogames: Boolean;
    sports: Boolean;
}

/// Public representation of retailer data.
class RetailerResponse {
    /// Retailer's unique identifier.
    /// Not optional since we only return retailers that exist in the DB.
    id: Number;
    
    /// Retailer's full name.
    name: String;
    
    /// Retailer's email address.
    email: String;
}

class ProcessCouponResponse {
    // @todo our response from coupon processing
    timesProcessed: Number;
}

/// Public representation of couponIssuer data.
interface CouponIssuerResponse {
    /// CouponIssuer's unique identifier.
    /// Not optional since we only return couponIssuers that exist in the DB.
    id: Number;
    
    /// CouponIssuer's full name.
    name: String;
}