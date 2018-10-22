//
//  CouponIssuerController.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Crypto
import Vapor
import FluentSQLite

/// Creates new couponIssuers and logs them in.
final class CouponIssuerController {
    /// Logs a couponIssuer in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<CouponIssuerToken> {
        // get couponIssuer auth'd by basic auth middleware
        let couponIssuer = try req.requireAuthenticated(CouponIssuer.self)
        
        // create new token for this couponIssuer
        let token = try CouponIssuerToken.create(couponIssuerID: couponIssuer.requireID())
        
        // save and return token
        return token.save(on: req)
    }
    
    /// Creates a new couponIssuer.
    func create(_ req: Request) throws -> Future<CouponIssuerResponse> {
        // decode request content
        return try req.content.decode(CreateCouponIssuerRequest.self).flatMap { couponIssuer -> Future<CouponIssuer> in
            // verify that passwords match
            guard couponIssuer.password == couponIssuer.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            // hash couponIssuer's password using BCrypt
            let hash = try BCrypt.hash(couponIssuer.password)
            // save new couponIssuer
            return CouponIssuer(id: nil, name: "CouponIssuer", passwordHash: hash)
                .save(on: req)
            }.map { (couponIssuer: CouponIssuer) in
                // map to public couponIssuer response (omits password hash)
                return try CouponIssuerResponse(id: couponIssuer.requireID(), name: couponIssuer.name)
        }
    }
    
    func postCoupon(_ req: Request) throws -> Future<Coupon> {
        return try req.content.decode(CreateCouponRequest.self).flatMap { newCoupon in
            return Coupon(title: newCoupon.title, retailerID: newCoupon.retailerID)
                .save(on: req)
        }
    }
    
    func assignShopperToCoupon(_ req: Request) throws -> Future<ProcessCouponResponse> {
        return try req.content.decode(ShopperToCoupon.self).flatMap { stc -> Future<ShopperToCoupon> in
            // @todo process here (add more processing stuff here)
            stc.timesProcessed += 1
            return stc.save(on: req)
            }.map { stc in
                return ProcessCouponResponse(id: stc.id!, shopperID: stc.shopperID, couponID: stc.couponID, timesProcessed: stc.timesProcessed)
            }
    }
}

// MARK: Content

/// Data required to create a couponIssuer.
struct CreateCouponIssuerRequest: Content {
    /// CouponIssuer's full name.
    var name: String
    
    /// CouponIssuer's email address.
    var email: String
    
    /// CouponIssuer's desired password.
    var password: String
    
    /// CouponIssuer's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

struct CreateCouponRequest: Content {
    var title: String
    /// Reference to Retailer that owns this Coupon.
    var retailerID: Retailer.ID
}

/// Public representation of couponIssuer data.
struct CouponIssuerResponse: Content {
    /// CouponIssuer's unique identifier.
    /// Not optional since we only return couponIssuers that exist in the DB.
    var id: Int
    
    /// CouponIssuer's full name.
    var name: String
}
