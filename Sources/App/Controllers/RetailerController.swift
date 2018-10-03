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
        return try req.content.decode(ShopperToCoupon.self).flatMap { stc -> Future<ShopperToCoupon> in
            // @todo process here (add more processing stuff here)
            stc.timesProcessed += 1
            return stc.save(on: req)
            }.map { stc in
                return ProcessCouponResponse(timesProcessed: stc.timesProcessed)
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
    // @todo our response from coupon processing
    var timesProcessed: Int
}
