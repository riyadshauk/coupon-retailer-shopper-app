//
//  ShopperPreferences.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import FluentSQLite
import Vapor

/// A single entry of a todo list.
final class ShopperPreferences: SQLiteModel {
    /// The unique identifier for this `ShopperPreferences`.
    var id: Int?
    
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
    
//    var shopperPreferences: Dictionary<PreferenceItem, Bool>
    
    
    /// Creates a new `ShopperPreferences`.
    init(id: Int? = nil, shopperID: Shopper.ID, jeans: Bool? = false, shirts: Bool? = false, longsleeve: Bool? = false, shortsleeve: Bool? = false, computers: Bool? = false, videogames: Bool? = false, sports: Bool? = false) {
        self.id = id
        self.shopperID = shopperID
        
        self.jeans = jeans!
        self.shirts = shirts!
        self.longsleeve = longsleeve!
        self.shortsleeve = shortsleeve!
        self.computers = computers!
        self.videogames = videogames!
        self.sports = sports!
    }
}

extension ShopperPreferences {
    /// Fluent relation to shopper that owns this shopperPreferences.
    var shopper: Parent<ShopperPreferences, Shopper> {
        return parent(\.shopperID)
    }
}

/// Allows `ShopperPreferences` to be used as a Fluent migration.
extension ShopperPreferences: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(ShopperPreferences.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.shopperID)
            builder.field(for: \.jeans)
            builder.field(for: \.shirts)
            builder.field(for: \.longsleeve)
            builder.field(for: \.shortsleeve)
            builder.field(for: \.computers)
            builder.field(for: \.videogames)
            builder.field(for: \.sports)
            builder.reference(from: \.shopperID, to: \Shopper.id)
        }
    }
}

/// Allows `ShopperPreferences` to be encoded to and decoded from HTTP messages.
extension ShopperPreferences: Content { }

/// Allows `ShopperPreferences` to be used as a dynamic parameter in route definitions.
extension ShopperPreferences: Parameter { }
