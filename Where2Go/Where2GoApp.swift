import SwiftData
import SwiftUI

@main
struct Where2GoApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: TripItem.self)
    }
}
