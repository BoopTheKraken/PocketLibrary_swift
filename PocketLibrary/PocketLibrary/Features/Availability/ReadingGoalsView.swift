//
//  ReadingGoalsView.swift
//  PocketLibrary
//
//  Created by Tatiana Klimova on 11/4/25.
//
import SwiftUI

struct ReadingGoalsView: View {
    @AppStorage("goalBooks") private var goalBooks: Double = 12
    @AppStorage("booksRead") private var booksRead: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Reading Goal").font(.title2).bold()
            ProgressView(value: booksRead, total: goalBooks) {
                Text("You've read \(Int(booksRead)) of \(Int(goalBooks)) books!")
            }
            Stepper("Goal: \(Int(goalBooks))", value: $goalBooks, in: 1...100)
            Stepper("Completed: \(Int(booksRead))", value: $booksRead, in: 0...100)
        }
        .padding()
    }
}
#Preview {
    ReadingGoalsView()
        .modelContainer(DataService.container)
}
