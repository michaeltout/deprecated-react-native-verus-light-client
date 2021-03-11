//
//  WalletFolder.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

class WalletFolder {
    private var coinWallets: [String: CoinWallet]
    
    init() {
        self.coinWallets = [String: CoinWallet]()
    }
    
    func createWallet(coinId: String, coinProto: String, accountHash: String, address: String, port: Int, numAddresses: Int, viewingKeys: [String], spendParams: URL, outputParams: URL, birthday: Int) {
        let walletKey = getCoinKey(coinId: coinId, coinProtocol: coinProto, accountHash: accountHash)
        let endpoint = ["address": address, "port": String(port)]
        
        self.coinWallets[walletKey] = CoinWallet(coinId: coinId, coinProto: coinProto, endpoint: endpoint, accountHash: accountHash, viewingKeys: viewingKeys, spendParams: spendParams, outputParams: outputParams, birthday: birthday, accounts: numAddresses)
    }
    
    func openWallet(coinId: String, coinProto: String, accountHash: String) throws {
        let walletKey = getCoinKey(coinId: coinId, coinProtocol: coinProto, accountHash: accountHash)
        
        if let requestWallet = self.coinWallets[walletKey] {
            try requestWallet.open()
        } else {
            throw RequestError.badRequestParams(desc: coinId + " wallet not yet added, or failed to activate.")
        }
    }
    
    func closeWallet(coinId: String, coinProto: String, accountHash: String) throws {
        let walletKey = getCoinKey(coinId: coinId, coinProtocol: coinProto, accountHash: accountHash)
        
        if let requestWallet = self.coinWallets[walletKey] {
            try requestWallet.close()
        } else {
            throw RequestError.badRequestParams(desc: coinId + " wallet not yet added, or failed to activate.")
        }
    }
    
    func deleteWallet(coinId: String, coinProto: String, accountHash: String) throws {
        let walletKey = getCoinKey(coinId: coinId, coinProtocol: coinProto, accountHash: accountHash)
        
        if let requestWallet = self.coinWallets[walletKey] {
            try requestWallet.deleteWallet()
        } else {
            throw RequestError.badRequestParams(desc: coinId + " wallet not yet added, or failed to activate.")
        }
    }
    
    func createAndOpenWallet(coinId: String, coinProto: String, address: String, port: Int, accountHash: String, numAddresses: Int, viewingKeys: [String], spendParams: URL, outputParams: URL, birthday: Int) throws {
        createWallet(coinId: coinId, coinProto: coinProto, accountHash: accountHash, address: address, port: port, numAddresses: numAddresses, viewingKeys: viewingKeys, spendParams: spendParams, outputParams: outputParams, birthday: birthday)
        
        try openWallet(coinId: coinId, coinProto: coinProto, accountHash: accountHash)
    }
    
    func makeJsRequest(coinId: String, coinProto: String, accountHash: String, id: Int?, method: String?, params: [String]?, completion: @escaping (Int?, Any?, RequestError?) -> ()) {
        let walletKey = getCoinKey(coinId: coinId, coinProtocol: coinProto, accountHash: accountHash)
        
        if let requestWallet = self.coinWallets[walletKey] {
            return requestWallet.makeJsRequest(id: id, method: method, params: params, completion: completion)
        } else {
            return completion(id, nil, RequestError.badRequestParams(desc: coinId + " wallet not yet added, or failed to activate."))
        }
    }
    
    func startCoinSync(coinId: String, coinProto: String, accountHash: String) throws {
        let walletKey = getCoinKey(coinId: coinId, coinProtocol: coinProto, accountHash: accountHash)
        
        if let requestWallet = self.coinWallets[walletKey] {
            try requestWallet.startSync()
        } else {
            throw RequestError.badRequestParams(desc: coinId + " wallet not yet added, or failed to activate.")
        }
    }
    
    func stopCoinSync(coinId: String, coinProto: String, accountHash: String) throws {
        let walletKey = getCoinKey(coinId: coinId, coinProtocol: coinProto, accountHash: accountHash)
        
        if let requestWallet = self.coinWallets[walletKey] {
            try requestWallet.stopSync()
        } else {
            throw RequestError.badRequestParams(desc: coinId + " wallet not yet added, or failed to activate.")
        }
    }
}
