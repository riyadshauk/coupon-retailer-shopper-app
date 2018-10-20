//
//  RetailerController.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Crypto
import Vapor
import FluentSQLite

/// Creates new retailers and logs them in.
final class RetailerController {
    /// Logs a retailer in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<RetailerToken> {
        // get retailer auth'd by basic auth middleware
        let retailer = try req.requireAuthenticated(Retailer.self)
        
        // create new token for this retailer
        let token = try RetailerToken.create(retailerID: retailer.requireID())
        
        // save and return token
        return token.save(on: req)
    }
    
    /// Creates a new retailer.
    func create(_ req: Request) throws -> Future<RetailerResponse> {
        // decode request content
        return try req.content.decode(CreateRetailerRequest.self).flatMap { retailer -> Future<Retailer> in
            // verify that passwords match
            guard retailer.password == retailer.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            // hash retailer's password using BCrypt
            let hash = try BCrypt.hash(retailer.password)
            // save new retailer
            return Retailer(id: nil, name: retailer.name, email: retailer.email, passwordHash: hash)
                .save(on: req)
            }.map { retailer in
                // map to public retailer response (omits password hash)
                return try RetailerResponse(id: retailer.requireID(), name: retailer.name, email: retailer.email)
        }
    }
}

extension RetailerController {
//    bearerRetailer.post("processCoupon", use: retailerController.processCoupon)
    func processCoupon(_ req: Request) throws -> Future<ProcessCouponResponse> {
        return try req.content.decode(ProcessCouponRequest.self).flatMap { processCouponRequest -> Future<[ShopperToCoupon]> in
            
            // @todo process here (we can add more processing stuff here, eg)
            
            let stclist = ShopperToCoupon.query(on: req)
                .filter(\ShopperToCoupon.shopperID == processCouponRequest.shopperID)
                .filter(\ShopperToCoupon.id == processCouponRequest.shopperToCouponID)
                .all()
            
                return stclist
            }.map { (stclist: [ShopperToCoupon]) in
                guard stclist.count > 0 else {
                    throw Abort(.badRequest, reason: "Invalid ProcessCouponRequest (the provided `shopperID` and `shopperToCouponID` pair does not exist in the database).")
                }
                let stc = stclist[0]
                stc.timesProcessed += 1
                _ = stc.save(on: req) // possible race condition between saving and sending back response (upon getting another request..? possibly consider later..)
                
                // https://docs.vapor.codes/3.0/vapor/client/
                let client = try req.client()
                let res = try client.post("http://coupon-issuer-url.com/endpoint") { post in
                    try post.content.encode(stc)
                }
                print("coupon-issuer-response: \(res)")
                
                return ProcessCouponResponse(id: stc.id!, shopperID: stc.shopperID, couponID: stc.couponID, timesProcessed: stc.timesProcessed)
        }
    }
}

// MARK: Content

/// Data required to create a retailer.
struct CreateRetailerRequest: Content {
    /// Retailer's full name.
    var name: String
    
    /// Retailer's email address.
    var email: String
    
    /// Retailer's desired password.
    var password: String
    
    /// Retailer's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

struct ProcessCouponRequest: Content {
    var shopperToCouponID: Int
    var shopperID: Int
}

/// Public representation of retailer data.
struct RetailerResponse: Content {
    /// Retailer's unique identifier.
    /// Not optional since we only return retailers that exist in the DB.
    var id: Int
    
    /// Retailer's full name.
    var name: String
    
    /// Retailer's email address.
    var email: String
}

struct ProcessCouponResponse: Content {
    /// The unique identifier for this `ShopperToCoupon`.
    var id: Int
    
    /// Reference to Shopper that belongs to this ShopperToCoupon.
    var shopperID: Shopper.ID
    
    /// Reference to Coupon that belongs to this ShopperToCoupon.
    var couponID: Coupon.ID
    
    var timesProcessed: Int
}
