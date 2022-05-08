//
//  ApiResponse.swift
//  Projector
//
//  Created by Serginjo Melnik on 01/05/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import Foundation

struct ApiResponse {
    var isSuccess : Bool
    var message : String
    var returnedData : Data
}

struct Post: Decodable {
    let title, body, id: String
}

struct UserProfile: Decodable{
    let id: String
    let createdAt: Int
    let updatedAt: Int
    let emailAddress: String
    let emailStatus: String
    let emailChangeCandidate: String
    let password: String
    let fullName: String
    let isSuperAdmin: Bool
    let passwordResetToken: String
    let passwordResetTokenExpiresAt: Int
    let emailProofToken: String
    let emailProofTokenExpiresAt: Int
    let stripeCustomerId: String
    let hasBillingCard: Bool
    let billingCardBrand: String
    let billingCardLast4: String
    let billingCardExpMonth: String
    let billingCardExpYear: String
    let tosAcceptedByIp: String
    let lastSeenAt: Int
}
