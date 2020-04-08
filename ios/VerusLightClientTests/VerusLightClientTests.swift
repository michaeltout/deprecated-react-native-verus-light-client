//
//  VerusLightClientTests.swift
//  VerusLightClientTests
//
//  Created by Michael Filip Toutonghi on 28/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import XCTest
@testable import ZcashLightClientKit
@testable import VerusLightClient

class VerusLightClientTests: XCTestCase {

    var dbData: URL? = nil
    
    override func setUp() {
        do {
            let dataDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            dbData = dataDir.appendingPathComponent("data.db")
        } catch {
            print(error)
        }
    }
    
    override func tearDown() {
        // Delete test database between runs
        do {
            try FileManager.default.removeItem(at: dbData!)
        } catch {
        }
    }
    
    func testInitAndGetAddress() {
        let seed = "a seed that is at least 32 bytes long so that it will work with the ZIP 32 protocol."
        
        XCTAssertNoThrow(try ZcashRustBackend.initDataDb(dbData: dbData!))
        XCTAssertEqual(ZcashRustBackend.getLastError(), nil)
        
        let _ = ZcashRustBackend.initAccountsTable(dbData: dbData!, seed: Array(seed.utf8), accounts: 2)
        XCTAssertEqual(ZcashRustBackend.getLastError(), nil)
        
        // Test first account
        let addr = ZcashRustBackend.getAddress(dbData: dbData!, account: 0)
        XCTAssertEqual(ZcashRustBackend.getLastError(), nil)
        XCTAssertEqual(addr, Optional("ztestsapling15pz88vyay93lahgwze9m8vz9hkxe9796ax3ks9rzhkt7dknff0jqafnrttx0muq47vp2sadupwl"))
        
        // Test second account
        let addr2 = ZcashRustBackend.getAddress(dbData: dbData!, account: 1)
        XCTAssertEqual(ZcashRustBackend.getLastError(), nil)
        XCTAssertEqual(addr2, Optional("ztestsapling1sp6me2wlze34lucw9tdctyqvxxcjtyudpq08kgx74g7ju6cy6ldxp3td3wp0s4e5rprn589d0lu"))
        
        // Test invalid account
        let addr3 = ZcashRustBackend.getAddress(dbData: dbData!, account: 3)
        XCTAssert(ZcashRustBackend.getLastError() != nil)
        XCTAssertEqual(addr3, nil)
    }

}
