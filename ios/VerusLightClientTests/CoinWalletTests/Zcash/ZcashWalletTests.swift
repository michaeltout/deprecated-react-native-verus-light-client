//
//  ZcashWalletTests.swift
//  VerusLightClientTests
//
//  Created by Michael Filip Toutonghi on 29/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import XCTest
@testable import VerusLightClient
@testable import ZcashLightClientKit

class ZcashWalletTests: XCTestCase {
    var zcashWallet: CoinWallet? = nil

    override func setUp() {
        let testBundle = Bundle(for: type(of: self))
        
        zcashWallet = CoinWallet(coinId: "ZEC", coinProto: "btc", endpoint: ["address": "lightwalletd.testnet.z.cash", "port": "9067"], accountHash: "abcde12345", seed: "a seed that is at least 32 bytes long so that it will work with the ZIP 32 protocol.", spendParams: testBundle.url(forResource: "sapling-spend", withExtension: ".params")!, outputParams: testBundle.url(forResource: "sapling-output", withExtension: ".params")!)
    }

    override func tearDown() {
        try! zcashWallet!.stopSync()
    }

    func testOpenZecWallet() {
        XCTAssertNoThrow(try zcashWallet!.open())
    }
    
    func testGetAllWalletAddresses() {
        do {
            try zcashWallet!.open()
            
            let addresses = try zcashWallet!.listAddresses()
            XCTAssertEqual(addresses.count, 100)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testGetOneWalletAddress() {
        do {
            try zcashWallet!.open()
            
            let address = try zcashWallet!.getAddressByAccount(index: 5)
            XCTAssertEqual(address, "ztestsapling1u56tf7n8sn9theaa4ncun0w5ljf82ajgma9f9ag77q4rxtasnt6avzy5sy8dgyq8j4tmwppuqfq")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testGetTotalBalance() {
        do {
            try zcashWallet!.open()
            
            let balance = try zcashWallet!.getTotalBalance(includePending: false)
            let balanceWithPending = try zcashWallet!.getTotalBalance(includePending: true)
            
            XCTAssertNotNil(balance)
            XCTAssertNotNil(balanceWithPending)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testGetZecSyncStateAndProgress() {
        do {
            guard let wallet = zcashWallet else {
                XCTFail()
                return
            }
            
            try wallet.open()
            let wait_time = 20.0
            let expectation = self.expectation(description: "Syncing blockchain...")
            
            let preSyncState = try wallet.getSyncState()
            
            XCTAssertEqual(preSyncState.percent, 0)
            XCTAssertEqual(preSyncState.height, 0)
            XCTAssertEqual(preSyncState.state, .stopped)
            
            try wallet.startSync()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + wait_time) {
                let postSyncState = try! wallet.getSyncState()
                
                XCTAssertTrue(postSyncState.percent > 0)
                XCTAssertTrue(postSyncState.height > 0)
                switch postSyncState.state {
                case .error(_):
                    XCTFail()
                default:
                    expectation.fulfill()
                }
            }
            
            waitForExpectations(timeout: 25.0, handler: nil)
        } catch {
            XCTAssertNil(error)
        }
    }
}
