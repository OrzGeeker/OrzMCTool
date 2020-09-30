
import Combine

final class MCDataStore: ObservableObject {
   @Published var servers: [MCServerInfo] = [MCServerInfo]()
}

struct MCServerInfo: Identifiable {
    var id: Int
    var host: String
    var slpPort: Int32
    var queryPort: Int32
    var rconPort: Int32
}
