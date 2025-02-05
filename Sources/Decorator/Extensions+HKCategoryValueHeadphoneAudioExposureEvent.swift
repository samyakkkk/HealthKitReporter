//
//  Extensions+HKCategoryValueHeadphoneAudioExposureEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import Foundation
import HealthKit

@available(iOS 14.2, *)
extension HKCategoryValueHeadphoneAudioExposureEvent: CustomStringConvertible {
    public var description: String {
        "HKCategoryValueHeadphoneAudioExposureEvent"
    }
    public var detail: String {
        switch self {
        case .sevenDayLimit:
            return "Seven Day Limit"
        @unknown default:
            return "Unknown"
        }
    }
}
