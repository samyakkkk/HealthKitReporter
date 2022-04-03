//
//  SeriesSampleRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 24.11.20.
//

import Foundation
import HealthKit
import CoreLocation

class SeriesSampleRetriever {
    @available(iOS 13.0, *)
    func makeHeartbeatSeriesQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping HeartbeatSeriesResultsDataHandler
    ) throws -> HKSampleQuery {
        let heartbeatSeries = SeriesType.heartbeatSeries
        guard
            let seriesType = heartbeatSeries.original as? HKSeriesType
        else {
            throw HealthKitError.invalidType(
                "Invalid HKSeriesType: \(heartbeatSeries)"
            )
        }
        let query = HKSampleQuery(
            sampleType: seriesType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                resultsHandler([], error)
                return
            }
            var series = [HeartbeatSeries]()
            var seriesError: Error?
            let group = DispatchGroup()
            for element in result {
                guard let seriesSample = element as? HKHeartbeatSeriesSample else {
                    resultsHandler(
                        [],
                        HealthKitError.invalidType(
                            "Sample \(element) is not HKHeartbeatSeriesSample"
                        )
                    )
                    return
                }
                var measurements = [HeartbeatSeries.Measurement]()
                group.enter()
                let heartbeatSeriesQuery = HKHeartbeatSeriesQuery(
                    heartbeatSeries: seriesSample
                ) { (_, timeSinceSeriesStart, precededByGap, done, error) in
                    guard error == nil else {
                        seriesError = error
                        group.leave()
                        return
                    }
                    let measurement = HeartbeatSeries.Measurement(
                        timeSinceSeriesStart: timeSinceSeriesStart,
                        precededByGap: precededByGap,
                        done: done
                    )
                    measurements.append(measurement)
                    if done {
                        let sample = HeartbeatSeries(sample: seriesSample, measurements: measurements)
                        series.append(sample)
                        group.leave()
                    }
                }
                healthStore.execute(heartbeatSeriesQuery)
            }
            group.notify(queue: .global()) {
                resultsHandler(series, seriesError)
            }
        }
        return query
    }
    func makeWorkoutRouteQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        dataHandler: @escaping WorkoutRouteDataHandler
    ) throws -> HKSampleQuery {
        let workoutRoute = SeriesType.workoutRoute
        guard #available(iOS 11.0, *) else {
            throw HealthKitError.notAvailable(
                "HKSeriesType is not available for the current iOS"
            )
        }
        guard
            let seriesType = workoutRoute.original as? HKSeriesType
        else {
            throw HealthKitError.invalidType(
                "Invalid HKSeriesType: \(workoutRoute)"
            )
        }
        let query = HKSampleQuery(
            sampleType: seriesType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let result = data
            else {
                dataHandler(nil, error)
                return
            }
            for element in result {
                guard let workoutRoute = element as? HKWorkoutRoute else {
                    dataHandler(
                        nil,
                        HealthKitError.invalidType(
                            "Sample \(element) is not HKHeartbeatSeriesSample"
                        )
                    )
                    return
                }
                let workoutRouteQuery = HKWorkoutRouteQuery(
                    route: workoutRoute
                ) { (query, locations, done, error) in
                    guard
                        error == nil,
                        let locations = locations
                    else {
                        dataHandler(nil, error)
                        return
                    }
                    let workoutRoute = WorkoutRoute(
                        locations: locations.map {
                            WorkoutRoute.Location(location: $0)
                        },
                        done: done
                    )
                    dataHandler(workoutRoute, nil)
                }
                healthStore.execute(workoutRouteQuery)
            }
        }
        return query
    }
    func makeAnchoredWorkoutRouteQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        dataHandler: @escaping WorkoutRouteDataHandler
    ) throws -> HKAnchoredObjectQuery {
        print("FYI: Fetching from Anchored Query");
        guard #available(iOS 11.0, *) else {
            throw HealthKitError.notAvailable(
                "HKSeriesType is not available for the current iOS"
            )
        }
        
        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate, anchor: nil, limit: limit) { (query, samples, deletedObjects, anchor, error) in
            
            guard
                error == nil,
                let result = samples
            else {
                dataHandler(nil, error)
                return
            }
            print("FYI: Received Route data");
            for element in result {
     
                self.updateRouteCords(healthStore: healthStore, element: element, dataHandler: dataHandler)
            }
            
        }
        routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
            
            guard
                error == nil,
                let result = samples
            else {
                dataHandler(nil, error)
                return
            }
            print("FYI: Received update for route data");
            for element in result {
    
                self.updateRouteCords(healthStore: healthStore, element: element, dataHandler: dataHandler)
            }
           
        }
       
        return routeQuery
    }
    @available(iOS 11.0, *)
    func updateRouteCords(
        healthStore: HKHealthStore,
        element: HKSample,
        dataHandler: @escaping WorkoutRouteDataHandler)-> Void{
        guard let workoutRoute = element as? HKWorkoutRoute else {
            dataHandler(
                nil,
                HealthKitError.invalidType(
                    "Series \(element) is not HKWorkoutRouteSample"
                )
            )
            return
        }
        let workoutRouteQuery = HKWorkoutRouteQuery(
            route: workoutRoute
        ) { (query, locations, done, error) in
            guard
                error == nil,
                let locations = locations
            else {
                dataHandler(nil, error)
                return
            }
            let workoutRoute = WorkoutRoute(
                locations: locations.map {
                    WorkoutRoute.Location(location: $0)
                },
                done: done
            )
            dataHandler(workoutRoute, nil)
        }
        healthStore.execute(workoutRouteQuery)
    }
}
