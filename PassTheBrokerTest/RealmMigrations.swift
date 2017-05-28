//
//  RealmMigrations.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 28/05/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class RealmMigrations {
    
    public static let schemaVersion: UInt64 = 1
    
    public static func migrationHandler(_ migration: Migration, _ oldSchemaVersion: UInt64) {
        switch oldSchemaVersion {
        case 0:
            // Added solutionDescription to Question, clear questions to retrieve solution description
            migration.deleteData(forType: Question.className())
        default:
            // Realm will handle everything itself
            break
        }
    }
}
