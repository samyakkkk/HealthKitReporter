//
//  HealthKitObserver.swift
//  HealthKitReporter
//
//  Created by Victor on 23.09.20.
//

import Foundation
import HealthKit

/// **HealthKitObserver** class for HK observing operations
public class HealthKitObserver {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Sets observer query for type
     - Parameter type: **ObjectType** type
     - Parameter predicate: **NSPredicate** predicate (optional). Nil by default
     - Parameter updateHandler: is called as soon any change happened in AppleHealth App
     */
    public func observerQuery(
        type: ObjectType,
        predicate: NSPredicate? = nil,
        updateHandler: @escaping ObserverUpdateHandler
    ) {
        guard let sampleType = type.original as? HKSampleType else {
            updateHandler(
                nil,
                nil,
                HealthKitError.invalidType("Unknown type: \(type)")
            )
            return
        }
        let query = HKObserverQuery(
            sampleType: sampleType,
            predicate: predicate
        ) { (query, completion, error) in
            guard error == nil else {
                updateHandler(query, nil, error)
                return
            }
            guard let id = query.objectType?.identifier else {
                updateHandler(
                    query,
                    nil,
                    HealthKitError.unknown("Unknown object type for query: \(query)")
                )
                return
            }
            updateHandler(query, id, nil)
            completion()
        }
        healthStore.execute(query)
    }
    /**
     Enables background notifications about changes in AppleHealth
     - Parameter type: **ObjectType** type
     - Parameter frequency: **HKUpdateFrequency** frequency. Hourly by default
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func enableBackgroundDelivery(
        type: ObjectType,
        frequency: UpdateFrequency = .hourly,
        completionHandler: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.original else {
            completionHandler(
                false,
                HealthKitError.invalidType("Unknown type: \(type)")
            )
            return
        }
        healthStore.enableBackgroundDelivery(
            for: objectType,
            frequency: frequency.original,
            withCompletion: completionHandler
        )
    }
    /**
     Disables All background notifications about changes in AppleHealth
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func disableAllBackgroundDelivery(
        completionHandler: @escaping StatusCompletionBlock
    ) {
        healthStore.disableAllBackgroundDelivery(completion: completionHandler)
    }
    /**
     Disables All background notifications about changes in AppleHealth
     - Parameter type: **ObjectType** type
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func disableBackgroundDelivery(
        type: ObjectType,
        completionHandler: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.original else {
            completionHandler(
                false,
                HealthKitError.invalidType("Unknown type: \(type)")
            )
            return
        }
        healthStore.disableBackgroundDelivery(
            for: objectType,
            withCompletion: completionHandler
        )
    }
}
