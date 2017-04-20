//
//  StringExtension.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 20/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import Foundation

extension String {
    
    static func format(_ value: Double, precision: Int, ignorePrecisionIfRounded: Bool) -> String {
        var precision = precision
        if ignorePrecisionIfRounded && value-floor(value) == 0 {
            precision = 0
        }
        
        return String(format: "%.\(precision)f", value)
    }
    
    static func format(_ value: Double, precision: Int) -> String {
        return format(value, precision: precision, ignorePrecisionIfRounded: false)
    }
}
