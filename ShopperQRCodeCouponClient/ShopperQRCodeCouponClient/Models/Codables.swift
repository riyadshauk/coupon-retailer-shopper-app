//
//  Codables.swift
//  ShopperQRCodeCouponClient
//
//  Created by Riyad Shauk on 10/23/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

struct ShopperLoginRequest: Encodable {
    let shopperEmail: String
    let shopperPassword: String
}
struct ShopperLoginResponse: Decodable {
    var id: Int
    var string: String
    var shopperID: Int
    var expiresAt: String
}
struct ShopperToCouponResponse: Decodable {
    var id: Int
    var shopperID: Int
    var couponID: Int
    var start: String
    var end: String
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
}
