//
//  Extensions+HKCategoryValueAppleStandHour.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import Foundation
import HealthKit

extension HKCategoryValueAppleStandHour: CustomStringConvertible {
    public var description: String {
        "HKCategoryValueAppleStandHour"
    }
    public var detail: String {
        switch self {
        case .stood:
            return "Stood"
        case .idle:
            return "Idle"
        @unknown default:
            return "Unknown"
        }
    }
}
