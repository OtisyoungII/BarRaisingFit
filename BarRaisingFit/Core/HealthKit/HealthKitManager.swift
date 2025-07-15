//
//  HealthKitManager.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    // MARK: - Request Permissions

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ Health data not available on this device.")
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        ]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ HealthKit authorization failed: \(error.localizedDescription)")
                } else if success {
                    print("✅ HealthKit permission granted.")
                } else {
                    print("❌ HealthKit permission denied.")
                }
                completion(success)
            }
        }
    }

    // MARK: - Step Count

    func fetchStepCount(completion: @escaping (Double?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            let steps = stats?.sumQuantity()?.doubleValue(for: .count())
            completion(steps)
        }

        healthStore.execute(query)
    }

    func startObservingStepCountUpdates(afterAuthorization: Bool = true, updateHandler: @escaping (Double) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, _, error in
            if let error = error {
                print("❌ Step count observer error: \(error.localizedDescription)")
                return
            }

            self.fetchStepCount { steps in
                DispatchQueue.main.async {
                    updateHandler(steps ?? 0)
                }
            }
        }

        healthStore.execute(query)

        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if success {
                print("✅ Background delivery enabled for step count.")
            } else if let error = error {
                print("❌ Background delivery failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Distance Walked

    func fetchDistanceWalked(completion: @escaping (Double?) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            let distance = stats?.sumQuantity()?.doubleValue(for: HKUnit.meter())
            completion(distance)
        }

        healthStore.execute(query)
    }

    // MARK: - Flights Climbed

    func fetchFlightsClimbed(completion: @escaping (Double?) -> Void) {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(nil)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            let flights = stats?.sumQuantity()?.doubleValue(for: HKUnit.count())
            completion(flights)
        }

        healthStore.execute(query)
    }

    // MARK: - Heart Rate

    func startHeartRateUpdates(updateHandler: @escaping (Double) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            if let sample = samples?.last as? HKQuantitySample {
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    updateHandler(bpm)
                }
            }
        }

        query.updateHandler = { _, samples, _, _, _ in
            if let sample = samples?.last as? HKQuantitySample {
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    updateHandler(bpm)
                }
            }
        }

        healthStore.execute(query)
    }
}
