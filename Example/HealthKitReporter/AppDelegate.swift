//
//  AppDelegate.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09/14/2020.
//  Copyright (c) 2020 Victor Kachalov. All rights reserved.
//

import UIKit
import HealthKitReporter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do {
            let reporter = try HealthKitReporter()
            reporter.manager.requestAuthorization(
                toRead: [.stepCount],
                toWrite: [.stepCount]
            ) { (success, error) in
                if success && error == nil {
                    reporter.observer.observerQuery(type: .stepCount) { (identifier, error) in
                        if error == nil {
                            print("updates for \(identifier)")
                        }
                    }
                    reporter.observer.enableBackgroundDelivery(
                        type: .stepCount,
                        frequency: .daily
                    ) { (success, error) in
                        if error == nil {
                            print("enabled")
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        return true
    }
}

