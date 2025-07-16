import Foundation

class StepDataManager: ObservableObject {
    static let shared = StepDataManager()

    private let userDefaultsKey = "stepHistory"
    @Published private(set) var stepHistory: [StepRecord] = []

    private init() {
        loadStepHistory()
    }

    func getStepHistory() -> [StepRecord] {
        return stepHistory
    }

    /// Public method to add or update a step count manually
    func addOrUpdateStepCount(_ stepCount: Double, on date: Date) {
        let record = StepRecord(date: date, stepCount: stepCount)
        addOrUpdateStep(from: record)
        saveStepHistory()
    }

    /// Sync with HealthKit over a date range (default: last 14 days)
func syncWithHealthKit(startingFrom startDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                           completion: (() -> Void)? = nil) {
        HealthKitManager.shared.fetchHistoricalSteps(startDate: startDate) { [weak self] healthKitSteps in
            guard let self = self else { return }
            
            for newRecord in healthKitSteps {
                self.addOrUpdateStep(from: newRecord)
                
            }
            
            self.saveStepHistory()
            
            print("✅ Step history synced from HealthKit")
            
            // ✅ Trigger the optional completion handler
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    /// Internal method to insert or replace a StepRecord by date
    private func addOrUpdateStep(from newRecord: StepRecord) {
        let normalizedDate = Calendar.current.startOfDay(for: newRecord.date)

        if let index = stepHistory.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)
        }) {
            stepHistory[index] = StepRecord(
                id: stepHistory[index].id,
                date: normalizedDate,
                stepCount: newRecord.stepCount
            )
        } else {
            stepHistory.append(StepRecord(date: normalizedDate, stepCount: newRecord.stepCount))
        }
    }

    /// Save step history to UserDefaults
    private func saveStepHistory() {
        do {
            let data = try JSONEncoder().encode(stepHistory)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("❌ Failed to save step history: \(error.localizedDescription)")
        }
    }

    /// Load step history from UserDefaults
    private func loadStepHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }

        do {
            stepHistory = try JSONDecoder().decode([StepRecord].self, from: data)
        } catch {
            print("❌ Failed to load step history: \(error.localizedDescription)")
            stepHistory = []
        }
    }
}
