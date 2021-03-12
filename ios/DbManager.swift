//
//  DbManager.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 01/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func generateDbUrls(coinId: String, coinProtocol: String, accountHash: String, spendParams: URL, outputParams: URL) throws -> WalletFiles {
    let dbPrefix = getCoinKey(coinId: coinId, coinProtocol: coinProtocol, accountHash: accountHash) + "_"
    let documentsDirectory = try __documentsDirectory()
    
    let cacheUrl = documentsDirectory.appendingPathComponent(dbPrefix+ZcashSDK.DEFAULT_CACHES_DB_NAME, isDirectory: false)
    let dataUrl = documentsDirectory.appendingPathComponent(dbPrefix+ZcashSDK.DEFAULT_DATA_DB_NAME, isDirectory: false)
    let pendingUrl = documentsDirectory.appendingPathComponent(dbPrefix+ZcashSDK.DEFAULT_PENDING_DB_NAME)
    
    return WalletFiles(cacheDb: cacheUrl, dataDb: dataUrl, pendingDb: pendingUrl, spendParams: spendParams, outputParams: outputParams)
}

func __documentsDirectory() throws -> URL {
    try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

// Bundle.main.url(forResource: "sapling-output", withExtension: ".params")!
