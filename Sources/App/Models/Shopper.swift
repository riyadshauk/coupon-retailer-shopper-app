//
//  Shopper.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Authentication
import FluentSQLite
import Vapor
//import CoreLocation // cannot use CoreLocation on Linux deployment

/// A registered shopper, capable of owning todo items.
final class Shopper: SQLiteModel {
    /// Shopper's unique identifier.
    /// Can be `nil` if the shopper has not been saved yet.
    var id: Int?
    
    /// Shopper's full name.
    var name: String
    
    /// Shopper's email address.
    var email: String
    
    /// BCrypt hash of the shopper's password.
    var passwordHash: String
    
    var latitude: Double
    
    var longitude: Double
    
    /// Creates a new `Shopper`.
    init(id: Int? = nil, name: String, email: String, passwordHash: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.latitude = latitude // location.coordinate.latitude
        self.longitude = longitude // location.coordinate.longitude
    }
}

/// Allows shoppers to be verified by basic / password auth middleware.
extension Shopper: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<Shopper, String> {
        return \.email
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<Shopper, String> {
        return \.passwordHash
    }
}

/// Allows shoppers to be verified by bearer / token auth middleware.
extension Shopper: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = ShopperToken
}

/// Allows `Shopper` to be used as a Fluent migration.
extension Shopper: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Shopper.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.email)
            builder.field(for: \.passwordHash)
            builder.field(for: \.latitude)
            builder.field(for: \.longitude)
            builder.unique(on: \.email)
        }
    }
}

/// Allows `Shopper` to be encoded to and decoded from HTTP messages.
extension Shopper: Content { }

/// Allows `Shopper` to be used as a dynamic parameter in route definitions.
extension Shopper: Parameter { }
