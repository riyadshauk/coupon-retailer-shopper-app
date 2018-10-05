//
//  ShopperController.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Crypto
import Vapor
import FluentSQLite
//import CoreLocation // cannot use CoreLocation on Linux deployment

/// Creates new shoppers and logs them in.
final class ShopperController {
    /// Logs a shopper in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<ShopperToken> {
        // get shopper auth'd by basic auth middleware
        let shopper = try req.requireAuthenticated(Shopper.self)
        
        // create new token for this shopper
        let token = try ShopperToken.create(shopperID: shopper.requireID())
        
        // save and return token
        return token.save(on: req)
    }
    
    /// Creates a new shopper.
    func create(_ req: Request) throws -> Future<ShopperResponse> {
        // decode request content
        return try req.content.decode(CreateShopperRequest.self).flatMap { shopper -> Future<Shopper> in
            // verify that passwords match
            guard shopper.password == shopper.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            // hash shopper's password using BCrypt
            let hash = try BCrypt.hash(shopper.password)
            // save new shopper
            return Shopper(id: nil, name: shopper.name, email: shopper.email, passwordHash: hash, latitude: 0, longitude: 0)
                .save(on: req)
            }.map { shopper in
                // map to public shopper response (omits password hash)
                return try ShopperResponse(id: shopper.requireID(), name: shopper.name, email: shopper.email, latitude: shopper.latitude, longitude: shopper.longitude)
        }
    }
}

extension ShopperController {
//    bearerShopper.post("preferences", use: shopperController.addPreferences)
//    bearerShopper.post("location", use: shopperController.updateCurrentLocation)
//    bearerShopper.get("relevantCoupon", use: shopperController.getRelevantCoupon)
    func upsertPreferences(_ req: Request) throws -> Future<ShopperPreferencesResponse> {
        // fetch auth'd shopper
        let shopper = try req.requireAuthenticated(Shopper.self)
        
        return try req.content.decode(UpsertShopperPreferencesRequest.self).flatMap { newPrefs -> Future<ShopperPreferences> in
            return try ShopperPreferences(shopperID: shopper.requireID(), jeans: newPrefs.jeans, shirts: newPrefs.shirts, longsleeve: newPrefs.longsleeve, shortsleeve: newPrefs.shortsleeve, computers: newPrefs.computers, videogames: newPrefs.videogames, sports: newPrefs.sports)
            .save(on: req)
            }.map { upedPrefs in
                return ShopperPreferencesResponse(id: upedPrefs.id!, jeans: upedPrefs.jeans, shirts: upedPrefs.shirts, longsleeve: upedPrefs.longsleeve, shortsleeve: upedPrefs.shortsleeve, computers: upedPrefs.computers, videogames: upedPrefs.videogames, sports: upedPrefs.sports)
        }
    }
    
    func updateCurrentLocation(_ req: Request) throws -> Future<ShopperResponse> {
        // fetch auth'd shopper
        let shopper = try req.requireAuthenticated(Shopper.self)
        
        return try req.content.decode(UpdateShopperLocationRequest.self).flatMap { shopperLocationRequest -> Future<Shopper> in
//            let loc = CLLocation(latitude: shopperLocationRequest.latitude, longitude: shopperLocationRequest.longitude)
            return Shopper(name: shopper.name, email: shopper.email, passwordHash: shopper.passwordHash, latitude: 0, longitude: 0)
                .save(on: req)
            }.map { updatedShopper in
                return try ShopperResponse(id: updatedShopper.requireID(), name: updatedShopper.name, email: updatedShopper.email, latitude: updatedShopper.latitude, longitude: updatedShopper.longitude)
        }
    }
    
    func getRelevantCoupons(_ req: Request) throws -> Future<[Coupon]> {
        // fetch auth'd shopper
        let shopper = try req.requireAuthenticated(Shopper.self)
        
        let coupons = Coupon.query(on: req)
        .join(\ShopperToCoupon.couponID, to: \Coupon.id)
        .filter(\Shopper.id == shopper.id)
        .all()
        return coupons
        
    }
}

// MARK: Content

/// Data required to create a shopper.
struct CreateShopperRequest: Content {
    /// Shopper's full name.
    var name: String
    
    /// Shopper's email address.
    var email: String
    
    /// Shopper's desired password.
    var password: String
    
    /// Shopper's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

struct UpdateShopperLocationRequest: Content {
    var email: String
    var password: String
    var latitude: Double
    var longitude: Double
}

struct UpsertShopperPreferencesRequest: Content {
    /// Reference to shopper that owns this ShopperPreferences.
    var shopperID: Shopper.ID
    
    // various shopper preferences...
    var jeans: Bool
    var shirts: Bool
    var longsleeve: Bool
    var shortsleeve: Bool
    var computers: Bool
    var videogames: Bool
    var sports: Bool
}

/// Public representation of shopper data.
struct ShopperResponse: Content {
    /// Shopper's unique identifier.
    /// Not optional since we only return shoppers that exist in the DB.
    var id: Int
    
    /// Shopper's full name.
    var name: String
    
    /// Shopper's email address.
    var email: String
    
    var latitude: Double
    
    var longitude: Double
}

struct ShopperPreferencesResponse: Content {
    var id: Int
    var jeans: Bool
    var shirts: Bool
    var longsleeve: Bool
    var shortsleeve: Bool
    var computers: Bool
    var videogames: Bool
    var sports: Bool
}
