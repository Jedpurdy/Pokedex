import SwiftUI
import UserNotifications

@main
struct PokedexApp: App {
    @StateObject private var viewModel = PokemonViewModel()  // ViewModel for managing Pokémon data

    init() {
        requestNotificationPermission()  // Request permission when the app starts
    }

    var body: some Scene {
        WindowGroup {
            PokemonListView()
                .environmentObject(viewModel) // Provide the ViewModel to the PokemonListView
        }
    }

    // Request notification permission when the app starts
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted for notifications.")
            } else {
                print("Permission denied for notifications.")
            }
        }
    }
}
