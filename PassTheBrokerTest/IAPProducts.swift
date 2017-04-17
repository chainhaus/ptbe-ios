//
//  IAPProducts.swift
//  PassTheBrokerTest
//
//  Created by Jamiel Sheikh on 4/17/17.
//  Copyright © 2017 Override Labs, Inc. All rights reserved.
//

import Foundation

public struct IAPProducts {
    
    public static let premiumQuestions = "PTBE1NYSALES"
    
    private static let productIdentifiers: Set<OverrideProductIdentifier> = [
        IAPProducts.premiumQuestions
    ]
    
    public static let store = IAPHelper(productIDs: IAPProducts.productIdentifiers)
}
