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
    private var heartRateQuery: HKAnchoredObjectQuery?
    private init() {}

    private func startOfToday() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ Health data not available on this device.")
            completion(false)
            return
        }

        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .activeEnergyBurned,
            .stepCount,
            .distanceWalkingRunning,
            .flightsClimbed
        ]

        let characteristicTypes: [HKCharacteristicTypeIdentifier] = [
            .biologicalSex,
            .dateOfBirth
        ]

        var readTypes = Set<HKObjectType>()

        for id in quantityTypes {
            if let type = HKObjectType.quantityType(forIdentifier: id) {
                readTypes.insert(type)
            }
        }

        for id in characteristicTypes {
            if let type = HKObjectType.characteristicType(forIdentifier: id) {
                readTypes.insert(type)
            }
        }

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

    func fetchStepCount(completion: @escaping (Double?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil)
            return
        }

        let startDate = startOfToday()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, error in
            if let error = error {
                print("❌ Error fetching step count: \(error.localizedDescription)")
                completion(nil)
                return
            }

            let steps = stats?.sumQuantity()?.doubleValue(for: .count())
            print("📥 Fetching step count...")
            completion(steps)
            print("📊 Step count result: \(steps ?? -1)")
        }

        healthStore.execute(query)
    }

    func fetchDistanceWalked(completion: @escaping (Double?) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil)
            return
        }

        let startDate = startOfToday()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, error in
            if let error = error {
                print("❌ Error fetching distance: \(error.localizedDescription)")
                completion(nil)
                return
            }

            let distance = stats?.sumQuantity()?.doubleValue(for: HKUnit.meter())
            print("📥 Fetching distance walked...")
            completion(distance)
            print("📏 Distance walked result: \(distance ?? -1)")
        }

        healthStore.execute(query)
    }

    func fetchFlightsClimbed(completion: @escaping (Double?) -> Void) {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(nil)
            return
        }

        let startDate = startOfToday()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, error in
            if let error = error {
                print("❌ Error fetching flights climbed: \(error.localizedDescription)")
                completion(nil)
                return
            }

            let flights = stats?.sumQuantity()?.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                print("📥 Fetching flights climbed...")
                completion(flights)
                print("🧗‍♂️ Flights climbed result: \(flights ?? -1)")
            }
        }

        healthStore.execute(query)
    }

    func fetchHistoricalSteps(startDate: Date, completion: @escaping ([StepRecord]) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }

        let now = Date()
        var interval = DateComponents()
        interval.day = 1

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: Calendar.current.startOfDay(for: startDate),
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, error in
            if let error = error {
                print("❌ Error fetching historical steps: \(error.localizedDescription)")
                completion([])
                return
            }

            var stepRecords: [StepRecord] = []

            if let statsCollection = results {
                statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        let steps = sum.doubleValue(for: .count())
                        let record = StepRecord(date: statistics.startDate, stepCount: steps)
                        stepRecords.append(record)
                    }
                }
            }

            DispatchQueue.main.async {
                print("📆 Historical steps fetched: \(stepRecords.count) days")
                completion(stepRecords)
            }
        }

        healthStore.execute(query)
    }

    func startObservingStepCountUpdates(updateHandler: @escaping (Double) -> Void) {
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
    func fetchActiveEnergy(completion: @escaping (Double?) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil)
            return
        }

        let startDate = startOfToday()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, error in
            if let error = error {
                print("❌ Error fetching active energy: \(error.localizedDescription)")
                completion(nil)
                return
            }

            let calories = stats?.sumQuantity()?.doubleValue(for: .kilocalorie())
            print("🔥 Fetching active energy...")
            completion(calories)
            print("⚡️ Active energy result: \(calories ?? -1)")
        }

        healthStore.execute(query)
    }

    func startHeartRateUpdates(updateHandler: @escaping (Double) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-3600), end: nil)

        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
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
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    func stopHeartRateUpdates() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            print("🛑 Stopped Heart Rate Updates")
        }
        heartRateQuery = nil
    }
    }

