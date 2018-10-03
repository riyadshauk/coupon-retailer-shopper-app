//
//  Coupon.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import FluentSQLite
import Vapor

/// A single entry of a todo list.
final class Coupon: SQLiteModel {
    /// The unique identifier for this `Coupon`.
    var id: Int?
    
    /// A title describing what this `Coupon` entails.
    var title: String
    
    /// Reference to Retailer that owns this Coupon.
    var retailerID: Retailer.ID
    
    /// Creates a new `Coupon`.
    init(id: Int? = nil, title: String, retailerID: Retailer.ID) {
        self.id = id
        self.title = title
        self.retailerID = retailerID
    }
}

extension Coupon {
    /// Fluent relation to retailer that owns this coupon.
    var retailer: Parent<Coupon, Retailer> {
        return parent(\.retailerID)
    }
}

/// Allows `Coupon` to be used as a Fluent migration.
extension Coupon: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Coupon.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.retailerID)
            builder.reference(from: \.retailerID, to: \Retailer.id)
        }
    }
}

/// Allows `Coupon` to be encoded to and decoded from HTTP messages.
extension Coupon: Content { }

/// Allows `Coupon` to be used as a dynamic parameter in route definitions.
extension Coupon: Parameter { }
