//
//  ContentView.swift
//  PocketLibrary
//
//  Updated to preview RootView
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .modelContainer(DataService.container)
}
