//
//  Codables.swift
//  QRCodeReader.swift
//
//  Created by Riyad Shauk on 10/23/18.
//  Copyright © 2018 Yannick Loriot. All rights reserved.
//

struct ProcessCouponRequest: Encodable {
    var shopperID: Int
    var shopperToCouponID: Int
}
struct ProcessCouponResponse: Decodable {
    var id: Int
    var shopperID: Int
    var couponID: Int
    var timesProcessed: Int
}
struct RetailerLoginRequest: Encodable {
    let retailerEmail: String
    let retailerPassword: String
}
struct RetailerLoginResponse: Decodable {
    var id: Int
    var string: String
    var retailerID: Int
    var expiresAt: String
}
