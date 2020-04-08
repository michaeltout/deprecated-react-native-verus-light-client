//
//  VerusApiTests.swift
//  VerusLightClientTests
//
//  Created by Michael Filip Toutonghi on 09/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import XCTest

class VerusApiTests: XCTestCase {
    var walletFolder: WalletFolder = WalletFolder()
    let vrscId = TestConfig.VrscConfig.coinId
    let vrscProto = TestConfig.VrscConfig.coinProto
    let vrscAddr = TestConfig.VrscConfig.address
    let vrscPort = TestConfig.VrscConfig.port
    let userAcct = TestConfig.accountHash
    let seed = TestConfig.seed
    let callId = 5

    override func setUp() {
        let saplingParams = getSaplingParams(testBundle: Bundle(for: type(of: self)))
        
        try! walletFolder.createAndOpenWallet(coinId: vrscId, coinProto: vrscProto, address: vrscAddr, port: vrscPort, accountHash: userAcct, numAddresses: 100, seed: seed, spendParams: saplingParams["spend"]!, outputParams: saplingParams["output"]!, birthday: 0)
    }

    func testGetVrscBlockCount() {
        let expectation = self.expectation(description: "Getting vrsc block count")
        var blocks: Any? = nil
        var callError: RequestError? = nil
        var resultId: Int = 5
        
        walletFolder.makeJsRequest(coinId: vrscId, coinProto: vrscProto, accountHash: userAcct, id: callId, method: "getblockcount", params: [], completion: { (id, result, error) in
            blocks = result
            callError = error
            resultId = id!
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 20, handler: nil)
        
        XCTAssertNotNil(blocks)
        XCTAssertNil(callError)
        XCTAssertEqual(resultId, callId)
    }
    
    func testGetVrscAddresses() {
        let expectation = self.expectation(description: "Getting vrsc address list")
        var addressList: Any? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        
        walletFolder.makeJsRequest(coinId: vrscId, coinProto: vrscProto, accountHash: userAcct, id: callId, method: "listaddresses", params: [], completion: { (id, result, error) in
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
    
    func testGetVrscTotalBalance() {
        let expectation = self.expectation(description: "Getting total private vrsc balance")
        var balance: Any? = nil
        var callError: RequestError? = nil
        var resultId: Int = 0
        
        walletFolder.makeJsRequest(coinId: vrscId, coinProto: vrscProto, accountHash: userAcct, id: callId, method: "getprivatebalance", params: [], completion: { (id, result, error) in
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
}
