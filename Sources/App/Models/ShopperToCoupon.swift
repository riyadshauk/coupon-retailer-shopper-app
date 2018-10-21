//
//  ShopperToCoupon.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import FluentSQLite
import Vapor

/// A single entry of a todo list.
final class ShopperToCoupon: SQLiteModel {
    /// The unique identifier for this `ShopperToCoupon`.
    var id: Int?
    
    /// Reference to Shopper that belongs to this ShopperToCoupon.
    var shopperID: Shopper.ID
    
    /// Reference to Coupon that belongs to this ShopperToCoupon.
    var couponID: Coupon.ID
    
    var start: Date
    
    var end: Date
    
    // progress = some multiple of earningUnit divided by earningGoal
    var progress: Double
    
    // ie: "steps"
    var earningUnit: String
    
    // ie: 100 (for 100 steps)
    var earningGoal: Double
    
    var isValid: Bool
    
    // initially must be initialized to false
    var isRedeemed: Bool
    
    var product: String
    
    var name: String
    
    var title: String
    
    // if productDiscountPercentage < 0, it's invalid
    var productDiscountPercentage: Double
    
    // if productDiscount < 0, it's invalid
    var productDiscount: Double
    
    var timesProcessed: Int
    
    /// Creates a new `ShopperToCoupon`.
    init(id: Int? = nil, shopperID: Shopper.ID, couponID: Coupon.ID, start: Date, end: Date, progress: Double, earningUnit: String, earningGoal: Double, isValid: Bool, product: String, name: String, title: String, productDiscountPercentage: Double, productDiscount: Double) {
        self.id = id
        self.shopperID = shopperID
        self.couponID = couponID
        self.start = start
        self.end = end
        self.progress = progress
        self.earningUnit = earningUnit
        self.earningGoal = earningGoal
        self.isValid = isValid
        self.isRedeemed = false
        self.product = product
        self.name = name
        self.title = title
        self.productDiscountPercentage = productDiscountPercentage
        self.productDiscount = productDiscount
        self.timesProcessed = 0
    }
}

/// @todo is this extension needed for ShopperToCoupon?
extension ShopperToCoupon {
    /// Fluent relation to shopper that belongs to this shopperToCoupon.
    var shopper: Parent<ShopperToCoupon, Shopper> {
        return parent(\.shopperID)
    }
    
    /// Fluent relation to coupon that belongs to this shopperToCoupon.
    var coupon: Parent<ShopperToCoupon, Coupon> {
        return parent(\.couponID)
    }
}

/// Allows `ShopperToCoupon` to be used as a Fluent migration.
extension ShopperToCoupon: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(ShopperToCoupon.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.shopperID)
            builder.field(for: \.couponID)
            builder.field(for: \.start)
            builder.field(for: \.end)
            builder.field(for: \.progress)
            builder.field(for: \.earningUnit)
            builder.field(for: \.earningGoal)
            builder.field(for: \.isValid)
            builder.field(for: \.isRedeemed)
            builder.field(for: \.product)
            builder.field(for: \.name)
            builder.field(for: \.title)
            builder.field(for: \.productDiscountPercentage)
            builder.field(for: \.productDiscount)
            builder.field(for: \.timesProcessed)
            builder.reference(from: \.shopperID, to: \Shopper.id)
            builder.reference(from: \.couponID, to: \Coupon.id)
            builder.unique(on: \.shopperID, \.couponID)
        }
    }
}

/// Allows `ShopperToCoupon` to be encoded to and decoded from HTTP messages.
extension ShopperToCoupon: Content { }

/// Allows `ShopperToCoupon` to be used as a dynamic parameter in route definitions.
extension ShopperToCoupon: Parameter { }
