//
//  StepHistoryView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/16/25.
//

import SwiftUI

struct StepHistoryView: View {
    @State private var history: [StepRecord] = []
    
    var body: some View {
        NavigationView {
            Group {
                if history.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No step history yet.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                        List {
                            ForEach(history.sorted(by: { $0.date > $1.date })) { record in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formattedDate(record.date))
                                            .font(.headline)
                                        Text("Steps: \(Int(record.stepCount))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if let diff = stepDifference(for: record) {
                                        Text(diff > 0 ? "↑ \(Int(diff))" : "↓ \(abs(Int(diff)))")
                                            .foregroundColor(diff > 0 ? .green : .red)
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
            }
            .navigationTitle("Step History")
            .onAppear {
                StepDataManager.shared.syncWithHealthKit() // Fetch latest from HealthKit
                history = StepDataManager.shared.getStepHistory() // Then load it from local cache
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
        
    }
    
    private func stepDifference(for record: StepRecord) -> Double? {
        guard let index = history.firstIndex(where: { $0.id == record.id }),
                          index + 1 < history.count else {
                              return nil
                          }
        let previous = history[index + 1]
        return record.stepCount - previous.stepCount
    }
}
