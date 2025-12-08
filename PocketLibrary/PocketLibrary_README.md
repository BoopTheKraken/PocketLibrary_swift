# Folder Structure


```
PocketLibrary/
 ├── App/
 │    ├── PocketLibraryApp.swift
 │    └── RootView.swift
 │
 ├── Shared/
 │    ├── Models/                # Book, Branch, Reservation, Review, FineRecord
 │    ├── Services/              # API mocks, Core Data, Notifications
 │    └── Theme/                 # Colors, typography, accessibility
 │
 ├── Features/
 │    ├── Availability/         
 │    ├── SearchAndQR/          
 │    ├── SocialAndAlerts/      
 │    └── PaymentsAndRecs/      
 │
 └── README.md

```

# Team Roles

| Member | Role                    | Core Responsibilities                       |
| :----- | :---------------------- | :------------------------------------------ |
|        | iOS Developer           | Availability & Reservations + Reading Goals |
|        | UI/UX Designer          | Search / Filters + QR Card + MapKit         |
|        | Backend / State Manager | Notifications + Reviews + Achievements      |
|        | QA & Integration Lead   | Payments + Recommendations + Dark Mode      |

Each teammate works inside their **Feature folder**, referencing shared models and services.

# Shared Code Foundations

* **Models** (`Shared/Models/Models.swift`): `Book`, `Branch`, `Reservation`, `Review`, `FineRecord`
* **Services**

  * `LibraryAPI.swift` – Mock data & async methods
  * `FineHistoryStore.swift` – UserDefaults persistence
  * `DueDateNotifier.swift` – Local notifications
* **Theme**

  * `Theme.swift` – Color + accessibility helpers

# Setup Instructions

**https://github.com/BoopTheKraken/PocketLibrary_swift.git**

* Open in Xcode 15+
* Select PocketLibraryApp.swift as the scheme.

* Target iOS 17+.
* Run the app

* Press Run or use Cmd + R.
* Simulate data

* The project uses a MockLibraryAPI by default, so it runs offline.



# Shared foundations (everyone uses)

**Models (Shared/Models/Models.swift)**

```
import Foundation
import CoreLocation

struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var author: String
    var genre: String
    var isbn: String
    var isBorrowed: Bool
}

struct Branch: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var coordinate: CLLocationCoordinate2D
    var hours: String
    var availableCopies: Int
}

struct Reservation: Identifiable, Codable, Hashable {
    let id: UUID
    var book: Book
    var branchId: UUID
    var queuePosition: Int
    var createdAt: Date
}

struct Review: Identifiable, Codable, Hashable {
    let id: UUID
    var bookId: UUID
    var userName: String
    var rating: Int
    var comment: String
    var createdAt: Date
}

struct FineRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var bookTitle: String
    var amount: Double
    var date: Date
}

```


**Services (Shared/Services stubs)**

```
import Foundation
import CoreLocation

enum LibraryAPIError: Error { case network, decoding, unknown }

protocol LibraryAPI {
    func searchBooks(query: String) async throws -> [Book]
    func nearbyBranches(for book: Book, from location: CLLocationCoordinate2D, radiusKM: Double) async throws -> [Branch]
    func createReservation(bookId: UUID, branchId: UUID) async throws -> Reservation
    func fetchReviews(bookId: UUID) async throws -> [Review]
    func addReview(_ review: Review) async throws
}

final class MockLibraryAPI: LibraryAPI {
    func searchBooks(query: String) async throws -> [Book] { [] }
    func nearbyBranches(for book: Book, from location: CLLocationCoordinate2D, radiusKM: Double) async throws -> [Branch] { [] }
    func createReservation(bookId: UUID, branchId: UUID) async throws -> Reservation { .init(id: .init(), book: .init(id:.init(), title:"", author:"", genre:"", isbn:"", isBorrowed:false), branchId: .init(), queuePosition: 1, createdAt: .init()) }
    func fetchReviews(bookId: UUID) async throws -> [Review] { [] }
    func addReview(_ review: Review) async throws {}
}

```


```
// Persistence (Core Data & UserDefaults bridge) – let's keep simple starter
final class FineHistoryStore {
    private let key = "FineHistory"
    func save(_ fines: [FineRecord]) {
        if let encoded = try? JSONEncoder().encode(fines) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    func load() -> [FineRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([FineRecord].self, from: data) else { return [] }
        return decoded
    }
}

```

```
// Notifications
import UserNotifications
enum DueDateNotifier {
    static func scheduleDueSoon(for book: Book, secondsFromNow: TimeInterval = 48*3600) {
        let content = UNMutableNotificationContent()
        content.title = "Book Due Soon!"
        content.body  = "Your copy of \(book.title) is due in 2 days."
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsFromNow, repeats: false)
        let request = UNNotificationRequest(identifier: book.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

```


# Feature Workflows

### Person 1– Availability + Reservations + Goals

#### Implement search and availability lookup

**1. Availability (Features/Availability/AvailabilityViewModel.swift)**

```
import SwiftUI
import CoreLocation

@MainActor
final class AvailabilityViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Book] = []
    @Published var selectedBook: Book?
    @Published var branches: [Branch] = []
    @Published var isLoading = false

    private let api: LibraryAPI
    private let location: CLLocationCoordinate2D

    init(api: LibraryAPI = MockLibraryAPI(),
         location: CLLocationCoordinate2D = .init(latitude: 33.882, longitude: -117.885)) {
        self.api = api
        self.location = location
    }

    func search() async {
        guard !query.isEmpty else { results = []; return }
        isLoading = true
        defer { isLoading = false }
        results = (try? await api.searchBooks(query: query)) ?? []
    }

    func loadBranches(for book: Book) async {
        selectedBook = book
        branches = (try? await api.nearbyBranches(for: book, from: location, radiusKM: 25)) ?? []
    }
}

```


2) **Availability View (Features/Availability/AvailabilityView.swift)**
   ```


   import SwiftUI

   struct AvailabilityView: View {
       @StateObject private var vm = AvailabilityViewModel()

       var body: some View {
           NavigationStack {
               VStack {
                   TextField("Search by title, author, ISBN", text: $vm.query)
                       .textFieldStyle(.roundedBorder)
                       .padding(.horizontal)
                   Button("Search") { Task { await vm.search() } }
                       .buttonStyle(.borderedProminent)

                   List(vm.results) { book in
                       Button {
                           Task { await vm.loadBranches(for: book) }
                       } label {
                           VStack(alignment: .leading) {
                               Text(book.title).font(.headline)
                               Text(book.author).foregroundStyle(.secondary)
                           }
                       }
                   }

                   if let book = vm.selectedBook {
                       SectionHeader("Nearby branches for \(book.title)")
                       List(vm.branches) { b in
                           HStack { Text(b.name); Spacer(); Text("\(b.availableCopies) available") }
                       }
                       .frame(maxHeight: 220)
                   }
               }
               .navigationTitle("Availability")
           }
       }
   }

   private struct SectionHeader: View {
       var text: String
       init(_ t: String) { text = t }
       var body: some View { Text(text).font(.subheadline).bold().padding(.top) }
   }

   ```

#### Manage branch data and reservation queue

```
@MainActor
final class ReservationViewModel: ObservableObject {
    @Published var reservations: [Reservation] = []

    private let api: LibraryAPI
    init(api: LibraryAPI = MockLibraryAPI()) { self.api = api }

    func reserve(book: Book, at branchId: UUID) async {
        if let r = try? await api.createReservation(bookId: book.id, branchId: branchId) {
            reservations.append(r)
        }
    }
}

```

#### Track reading goal progress (`ProgressView`)

```
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

```

### Person 2 – Search / QR / MapKit

Genre filters and advanced search

1. **Search & Filters (Features/SearchAndQR/SearchViewModel.swift)**

```
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var selectedGenre: String = "Fiction"
    @Published var allBooks: [Book] = []
    @Published var filtered: [Book] = []

    private let api: LibraryAPI
    init(api: LibraryAPI = MockLibraryAPI()) { self.api = api }

    func load() async {
        allBooks = (try? await api.searchBooks(query: "")) ?? []
        applyFilters()
    }

    func applyFilters() {
        filtered = allBooks.filter { $0.genre == selectedGenre || selectedGenre == "All" }
    }
}

```

2. **Search View (Features/SearchAndQR/SearchView.swift)**

```
import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()
    private let genres = ["All","Fiction","Non-Fiction","Sci-Fi","Fantasy","History"]

    var body: some View {
        VStack {
            Picker("Genre", selection: $vm.selectedGenre) {
                ForEach(genres, id:\.self, content: Text.init)
            }.pickerStyle(.segmented)
             .padding()
             .onChange(of: vm.selectedGenre) { _ in vm.applyFilters() }

            List(vm.filtered) { book in
                VStack(alignment: .leading) {
                    Text(book.title).font(.headline)
                    Text(book.author).foregroundStyle(.secondary)
                }
            }
        }
        .task { await vm.load() }
        .navigationTitle("Search")
    }
}

```

#### Digital QR library card `(CIFilter.qrCodeGenerator()`)

3. **QR Card (Features/SearchAndQR/QRCardView.swift)**

   ```
   import SwiftUI
   import CoreImage.CIFilterBuiltins

   struct QRCardView: View {
       @AppStorage("userLibraryID") private var userLibraryID: String = "LBR-1234-5678"
       private let context = CIContext()
       private let filter = CIFilter.qrCodeGenerator()

       var body: some View {
           VStack(spacing: 16) {
               if let uiImage = makeQR(from: userLibraryID) {
                   Image(uiImage: uiImage)
                       .interpolation(.none)
                       .resizable()
                       .scaledToFit()
                       .frame(width: 220, height: 220)
                       .padding()
               }
               Text("Library ID: \(userLibraryID)").font(.footnote).monospaced()
           }
           .navigationTitle("Library Card")
           .padding()
       }

       private func makeQR(from string: String) -> UIImage? {
           filter.message = Data(string.utf8)
           guard let output = filter.outputImage else { return nil }
           let scaled = output.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
           return UIImage(ciImage: scaled)
       }
   }

   ```

#### Interactive map with branch pins (`MapKit`)

4. **MapKit** **Branch Map (Features/SearchAndQR/BranchMapView.swift)**

```
import SwiftUI
import MapKit

struct BranchAnnotation: Identifiable {
    let id = UUID()
    let branch: Branch
}

struct BranchMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.882, longitude: -117.885),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    var branches: [Branch] = [] // inject from Availability/Search

    var body: some View {
        Map(initialPosition: .region(region)) {
            ForEach(branches.map { BranchAnnotation(branch: $0) }) { ann in
                Annotation(ann.branch.name, coordinate: ann.branch.coordinate) {
                    ZStack {
                        Circle().fill(.blue).frame(width: 12, height: 12)
                    }
                }
            }
        }
        .navigationTitle("Nearby Branches")
    }
}

```

### Person 3 – Reviews / Notifications / Achievements

#### Display & submit reviews (`List + @State`)

1. **Notifications (Features/SocialAndAlerts/NotificationsView.swift)**

```
import SwiftUI

struct NotificationsView: View {
    @State private var enabled = true
    @State private var sampleBook = Book(id:.init(), title:"Dune", author:"Frank Herbert", genre:"Sci-Fi", isbn:"", isBorrowed:true)

    var body: some View {
        Form {
            Toggle("Enable reminders", isOn: $enabled)
            Button("Schedule Due Reminder (Demo)") {
                if enabled { DueDateNotifier.scheduleDueSoon(for: sampleBook, secondsFromNow: 5) }
            }
        }
        .navigationTitle("Notifications")
    }
}

```

2. **Reviews (Features/SocialAndAlerts/ReviewsViewModel.swift)**

```
@MainActor
final class ReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    private let api: LibraryAPI
    init(api: LibraryAPI = MockLibraryAPI()) { self.api = api }

    func load(for bookId: UUID) async {
        reviews = (try? await api.fetchReviews(bookId: bookId)) ?? []
    }

    func add(review: Review) async {
        try? await api.addReview(review)
        reviews.insert(review, at: 0)
    }
}

```


#### Schedule due-date reminders (`UNUserNotificationCenter)`




#### Reading streak tracker using `@AppStorage`

4. **Achievements (Features/SocialAndAlerts/AchievementsView.swift)**
   ```
   import SwiftUI

   struct AchievementsView: View {
       @AppStorage("streakDays") private var streakDays = 0
       var body: some View {
           VStack(spacing: 12) {
               Text("Reading Streak").font(.title2).bold()
               Text("\(streakDays) days! ")
               Button("Add a day") { streakDays += 1 }
           }.padding()
       }
   }

   ```



### Person 4– Payments / Recommendations / Dark Mode

#### Manage fine payments & receipts (UserDefaults + Apple Pay Sandbox)

1. **Payments (Features/PaymentsAndRecs/PaymentsViewModel.swift)**

```
import SwiftUI

@MainActor
final class PaymentsViewModel: ObservableObject {
    @Published var fines: [FineRecord] = []
    private let store = FineHistoryStore()

    init() { fines = store.load() }

    func addFine(title: String, amount: Double) {
        fines.append(.init(id:.init(), bookTitle: title, amount: amount, date: .init()))
        store.save(fines)
    }

    func payAll() {
        // integrate Apple Pay later; for demo, clear and save receipt snapshot
        fines.removeAll()
        store.save(fines)
    }
}

```

2. **Payments View (Features/PaymentsAndRecs/PaymentsView.swift)**

```
import SwiftUI

struct PaymentsView: View {
    @StateObject private var vm = PaymentsViewModel()

    var body: some View {
        VStack {
            List(vm.fines) { fine in
                HStack {
                    VStack(alignment:.leading) {
                        Text(fine.bookTitle).bold()
                        Text(fine.date.formatted()).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(fine.amount, format: .currency(code: "USD"))
                        .bold()
                }
            }

            HStack {
                Button("Add Demo Fine") { vm.addFine(title: "1984", amount: 3.50) }
                Spacer()
                Button("Pay All (Sandbox)") { vm.payAll() }
                    .buttonStyle(.borderedProminent)
            }.padding(.horizontal)
        }
        .navigationTitle("Fines & Payments")
    }
}

```





#### Compute recommended titles

3. **Recommendations (Features/PaymentsAndRecs/RecommendationsView.swift)**

```
import SwiftUI

struct RecommendationsView: View {
    // Inject from Search/Availability when you wire things up
    var recentlyViewed: [Book] = []
    var allBooks: [Book] = []

    private var recommendations: [Book] {
        let genres = Set(recentlyViewed.map { $0.genre })
        return allBooks.filter { genres.contains($0.genre) && !$0.isBorrowed }
    }

    var body: some View {
        List(recommendations) { b in
            VStack(alignment:.leading) {
                Text(b.title).font(.headline)
                Text(b.author).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Recommended")
    }
}

```


#### Maintain Dark Mode & accessibility compliance

4. **Dark Mode & Accessibility (Shared/Theme/Theme.swift)**

```
import SwiftUI

extension Color {
    static let bg = Color("BackgroundColor")
    static let fg = Color("TextColor")
}

struct AccessibleText: ViewModifier {
    @Environment(\.sizeCategory) var size
    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(0.9)
            .accessibilityAddTraits(.isStaticText)
    }
}
extension View { func accessible() -> some View { modifier(AccessibleText()) } }

```


## Other Stuff

### Root wiring (App/RootView.swift)


```
import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { AvailabilityView() }
                .tabItem { Label("Availability", systemImage: "magnifyingglass") }

            NavigationStack { SearchView() }
                .tabItem { Label("Search", systemImage: "line.3.horizontal.decrease.circle") }

            NavigationStack { ReviewsView(book: .init(id:.init(), title:"Dune", author:"Frank Herbert", genre:"Sci-Fi", isbn:"", isBorrowed: false)) }
                .tabItem { Label("Social", systemImage: "text.bubble") }

            NavigationStack { PaymentsView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
    }
}

```

```
// App entry (App/PocketLibraryApp.swift)
import SwiftUI
@main
struct PocketLibraryApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}

```
