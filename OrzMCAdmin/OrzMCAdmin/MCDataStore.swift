
import Combine
import OrzMCCore
import Foundation

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
    
    var pingMs: Int
    var statusJSONString: String?
    
    
    func slpStatus() -> MCSLPStatus? {
        let jsonDecoder = JSONDecoder()
        if let data = statusJSONString?.data(using: .utf8) {
            let status = try? jsonDecoder.decode(MCSLPStatus.self, from: data)
            return status
        }
        return nil
    }
    
}

// SLP JSON解析 
struct MCSLPRichText: Codable {
    var bold: Bool?
    var italic: Bool?
    var underlined: Bool?
    var strikethrough: Bool?
    var obfuscated: Bool?
    var color: String?
    var text: String?
}
struct MCSLPDescription: Codable {
    var extra: [MCSLPRichText]
    var text: String
}

struct MCSLPPlayers: Codable {
    var max: Int
    var online: Int
}
struct MCSLPVersion: Codable {
    var name: String
    var `protocol`: Int
}
struct MCSLPStatus: Codable {
    var description: MCSLPDescription
    var players: MCSLPPlayers
    var version: MCSLPVersion
    var favicon: String
}
