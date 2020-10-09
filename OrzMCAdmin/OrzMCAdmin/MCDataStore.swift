
import Combine
import OrzMCCore

final class MCDataStore: ObservableObject {
    @Published var servers: [MCServerInfo] = [MCServerInfo]()
    @Published var showServerInfoView = false
}

struct MCServerInfo: Identifiable {
    var id: Int
    var host: String
    var slpPort: Int32
    var queryPort: Int32
    var rconPort: Int32
    
    var basicStatus: MCServerBasicStatus?
    var fullStatus: MCServerFullStatus?
    
}
