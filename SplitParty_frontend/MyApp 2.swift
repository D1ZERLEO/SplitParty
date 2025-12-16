import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            AppNavigator() // ✅ Здесь будет вся навигация
        }
    }
}
