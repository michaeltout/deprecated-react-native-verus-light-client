//
//  WalletFolderTests.swift
//  VerusLightClientTests
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import XCTest

class WalletFolderTests: XCTestCase {
    var walletFolder: WalletFolder? = nil

    override func setUp() {
        walletFolder = WalletFolder()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateOpenCloseZecWallet() {
        let saplingParams = getSaplingParams(testBundle: Bundle(for: type(of: self)))
        
        XCTAssertNoThrow(try walletFolder?.createAndOpenWallet(coinId: TestConfig.ZecConfig.coinId, coinProto: TestConfig.ZecConfig.coinProto, address: TestConfig.ZecConfig.address, port: TestConfig.ZecConfig.port, accountHash: TestConfig.accountHash, numAddresses: 100, seed: TestConfig.seed, spendParams: saplingParams["spend"]!, outputParams: saplingParams["output"]!, birthday: 0))
        
        XCTAssertNoThrow(try walletFolder?.closeWallet(coinId: TestConfig.ZecConfig.coinId, coinProto: TestConfig.ZecConfig.coinProto, accountHash: TestConfig.accountHash))
    }
    
    func testCreateOpenDeleteZecWallet() {
        let saplingParams = getSaplingParams(testBundle: Bundle(for: type(of: self)))
        
        XCTAssertNoThrow(try walletFolder?.createAndOpenWallet(coinId: TestConfig.ZecConfig.coinId, coinProto: TestConfig.ZecConfig.coinProto, address: TestConfig.ZecConfig.address, port: TestConfig.ZecConfig.port, accountHash: TestConfig.accountHash, numAddresses: 100, seed: TestConfig.seed, spendParams: saplingParams["spend"]!, outputParams: saplingParams["output"]!, birthday: 0))
        
        XCTAssertNoThrow(try walletFolder?.deleteWallet(coinId: TestConfig.ZecConfig.coinId, coinProto: TestConfig.ZecConfig.coinProto, accountHash: TestConfig.accountHash))
    }
}
