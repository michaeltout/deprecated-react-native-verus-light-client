//
//  ZcashApiTests.swift
//  VerusLightClientTests
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import XCTest

class ZcashApiTests: XCTestCase {
    var walletFolder: WalletFolder = WalletFolder()
    let zecId = TestConfig.ZecConfig.coinId
    let zecProto = TestConfig.ZecConfig.coinProto
    let zecAddr = TestConfig.ZecConfig.address
    let zecPort = TestConfig.ZecConfig.port
    let userAcct = TestConfig.accountHash
    let seed = TestConfig.seed
    let callId = 5

    override func setUp() {
        let saplingParams = getSaplingParams(testBundle: Bundle(for: type(of: self)))
        
        try! walletFolder.createAndOpenWallet(coinId: zecId, coinProto: zecProto, address: zecAddr, port: zecPort, accountHash: userAcct, numAddresses: 100, seed: seed, spendParams: saplingParams["spend"]!, outputParams: saplingParams["output"]!, birthday: 0)
    }

    func testGetZecBlockCount() {
        let expectation = self.expectation(description: "Getting zec block count")
        var blocks: Any? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        
        walletFolder.makeJsRequest(coinId: zecId, coinProto: zecProto, accountHash: userAcct, id: callId, method: "getblockcount", params: [], completion: { (id, result, error) in
            blocks = result
            callError = error
            resultId = id!
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(blocks)
        XCTAssertNil(callError)
        XCTAssertEqual(resultId, callId)
    }
    
    func testGetZecAddresses() {
        let expectation = self.expectation(description: "Getting zec address list")
        var addressList: Any? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        
        walletFolder.makeJsRequest(coinId: zecId, coinProto: zecProto, accountHash: userAcct, id: callId, method: "listaddresses", params: [], completion: { (id, result, error) in
            addressList = result
            callError = error
            resultId = id!
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(addressList)
        XCTAssertNil(callError)
        XCTAssertEqual(resultId, callId)
    }
    
    func testGetZecTotalBalance() {
        let expectation = self.expectation(description: "Getting total zec balance")
        var balance: Any? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        
        walletFolder.makeJsRequest(coinId: zecId, coinProto: zecProto, accountHash: userAcct, id: callId, method: "getprivatebalance", params: [], completion: { (id, result, error) in
            balance = result
            callError = error
            resultId = id!
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(balance)
        XCTAssertNil(callError)
        XCTAssertEqual(resultId, callId)
    }
    
    func testGetZecOneAddressBalance() {
        let expectation = self.expectation(description: "Getting one zec address balance")
        var balance: Any? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        
        walletFolder.makeJsRequest(coinId: zecId, coinProto: zecProto, accountHash: userAcct, id: callId, method: "z_getbalance", params: [ "ztestsapling12dqs5nrpc9fppc5accmv4agnpnpg530e4lgwkufv6yhqvzf39yymkxjvjz8h6ft084erkseryf4", "true"], completion: { (id, result, error) in
            balance = result
            callError = error
            resultId = id!
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(balance)
        XCTAssertNil(callError)
        XCTAssertEqual(resultId, callId)
    }
    
    func testListZecTransactions() {
        let expectation = self.expectation(description: "Listing ZEC Z transactions")
        var transactions: [[String: Any?]]? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        
        walletFolder.makeJsRequest(coinId: zecId, coinProto: zecProto, accountHash: userAcct, id: callId, method: "listprivatetransactions", params: ["all"], completion: { (id, result, error) in
            transactions = result as? [[String: Any?]]
            callError = error
            resultId = id!
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(transactions)
        XCTAssertNil(callError)
        XCTAssertEqual(resultId, callId)
    }
    
    func testZecGetInfo() {
        let expectation = self.expectation(description: "Getting ZEC sync info")
        let wait_time = 10.0
        var infoDict: [String: Any?]? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        try! walletFolder.startCoinSync(coinId: zecId, coinProto: zecProto, accountHash: userAcct)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + wait_time) {
            self.walletFolder.makeJsRequest(coinId: self.zecId, coinProto: self.zecProto, accountHash: self.userAcct, id: self.callId, method: "getinfo", params: [], completion: { (id, result, error) in
                infoDict = (result as? [String: Any?]? ?? nil)
                guard let infoDictRes = infoDict else {
                    XCTFail()
                    expectation.fulfill()
                    return
                }
                
                callError = error
                resultId = id!
                
                XCTAssertNil(callError)
                XCTAssertEqual(resultId, self.callId)
                
                XCTAssertTrue(infoDictRes["percent"] as! Float > 0)
                XCTAssertTrue(infoDictRes["blocks"] as! Int > 0)
                XCTAssertTrue(infoDictRes["longestchain"] as! Int > 0)

                switch infoDictRes["status"] as! String {
                case "error",
                     "stopped":
                    XCTFail()
                default:
                    expectation.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        try! walletFolder.stopCoinSync(coinId: zecId, coinProto: zecProto, accountHash: userAcct)
    }
}
