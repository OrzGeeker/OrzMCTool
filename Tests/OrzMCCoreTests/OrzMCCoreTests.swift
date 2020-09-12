import XCTest
@testable import OrzMCCore

final class OrzMCCoreTests: XCTestCase {
    
    let host = "jokerhub.cn"

    func testQuery() {
        let query = MCQuery(host: self.host)
        XCTAssertNoThrow(try query.handshake())
        XCTAssertNoThrow(try query.basicStatus())
        XCTAssertNoThrow(try query.fullStatus())
    }
    
    func testServerListPing() {
        let slp = MCSLP(host: self.host)
        XCTAssertNoThrow(try slp.handshake())
        XCTAssertNoThrow(try slp.status())
    }
    
    func testRCON() {
        let rcon = MCRCON(host: self.host)
        XCTAssertNoThrow(try rcon.loginAndSendCmd(password: "543859230", cmd: "help"))
        XCTAssertNoThrow(try rcon.sendCmd("help"))
    }

    static var allTests = [
        ("testQuery", testQuery),
        ("testServerListPing", testServerListPing),
        ("testRCON", testRCON)
    ]
}
