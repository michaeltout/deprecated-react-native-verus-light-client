//
//  CoinWallet.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 01/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

class CoinWallet {
    private var wallet: Initializer?
    private var synchronizer: SDKSynchronizer?
    private var service: LightWalletService?
    private var files: WalletFiles?
    private var seed: String
    private var coinId: String
    private var coinProto: String
    private var endpoint: LightWalletEndpoint
    private var accountHash: String
    private var spendParams: URL
    private var outputParams: URL
    private var syncState: WalletSyncState
    var accounts: Int
    var birthday: Int

    init(coinId: String, coinProto: String, endpoint: [String: String], accountHash: String, seed: String, spendParams: URL, outputParams: URL, birthday: Int = 0, accounts: Int = 100) {
        self.seed = seed
        self.coinId = coinId
        self.endpoint = LightWalletEndpoint(address: endpoint["address"]!, port: Int(endpoint["port"]!)!, secure: true)
        self.wallet = nil
        self.synchronizer = nil
        self.service = nil
        self.files = nil
        self.syncState = WalletSyncState(percent: 0, height: 0, state: .stopped)
        self.coinId = coinId
        self.coinProto = coinProto
        self.accountHash = accountHash
        self.spendParams = spendParams
        self.outputParams = outputParams
        self.birthday = birthday
        self.accounts = accounts
    }
    
    func deleteWallet() throws {
        try stopSync()
        if let syncer = self.synchronizer {
            try syncer.stop()
        }
        
        if let walletFiles = self.files {
            try FileManager.default.removeItem(at: walletFiles.dataDb)
            try FileManager.default.removeItem(at: walletFiles.cacheDb)
            try FileManager.default.removeItem(at: walletFiles.pendingDb)
        }
    }
    
    func close() throws {
        try stopSync()
        
        if let syncer = self.synchronizer {
            try syncer.stop()
        }
    }
    
    deinit {
        if let syncer = self.synchronizer {
            try! syncer.stop()
        }
    }
    
    func open() throws {
        self.files = try generateDbUrls(coinId: self.coinId, coinProtocol: self.coinProto, accountHash: self.accountHash, spendParams: self.spendParams, outputParams: self.outputParams)
        
        if let walletFiles = self.files {
            self.wallet = Initializer(cacheDbURL: walletFiles.cacheDb, dataDbURL: walletFiles.dataDb, pendingDbURL: walletFiles.pendingDb, endpoint: self.endpoint, spendParamsURL: walletFiles.spendParams, outputParamsURL: walletFiles.outputParams)
            self.synchronizer = try SDKSynchronizer(initializer: self.wallet!)
                   self.service = LightWalletGRPCService(endpoint: self.endpoint)
            let _ = try self.wallet?.initialize(seedProvider: provideSeed(seed: self.seed), walletBirthdayHeight: self.birthday, numberOfAccounts: self.accounts)
            
            NotificationCenter.default.addObserver(self, selector: #selector(processorNotification(_:)), name: nil, object: wallet!.blockProcessor())
        }
    }
    
    func startSync() throws {
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        try openWallet.blockProcessor()?.start()
    }
    
    func stopSync() throws {
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        openWallet.blockProcessor()?.stop()
    }
    
    func getSyncState() throws -> WalletSyncState {
        guard wallet != nil else { throw CoinWalletGeneralError.walletUnopened }
        
        return syncState
    }
    
    @objc func processorNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard self.wallet != nil else { return }
            guard self.wallet?.blockProcessor() != nil else { return }
                        
            switch notification.name {
            case let not where not == Notification.Name.blockProcessorUpdated:
                guard let progress = notification.userInfo?[CompactBlockProcessorNotificationKey.progress] as? Float else { return }
                guard let progressHeight = notification.userInfo?[CompactBlockProcessorNotificationKey.progressHeight] as? Int else { return }
                guard let syncStatus = self.wallet!.blockProcessor()?.state else { return }
                
                self.syncState = WalletSyncState(percent: progress*100, height: progressHeight, state: syncStatus)
            default:
                return
            }
        }
    }
    
    private func provideSeed(seed: String) -> SeedBox {
        return SeedBox(seedString: seed)
    }
    
    func getInitializer() throws -> Initializer {
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        return openWallet
    }
    
    func getSynchronizer() throws -> SDKSynchronizer {
        guard let syncer = synchronizer else { throw CoinWalletGeneralError.walletUnopened }
        return syncer
    }
    
    func getService() throws -> LightWalletService {
        guard let server = service else { throw CoinWalletGeneralError.walletUnopened }
        return server
    }
    
    func makeJsRequest(id: Int?, method: String?, params: [String]?, completion: @escaping (Int?, Any?, RequestError?) -> ()) {
        return handleJsRequest(wallet: self, id: id, method: method, params: params, completion: completion)
    }
    
    func getAccountIndex(address: String) throws -> Int {
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        
        for n in 0...(self.accounts - 1) {
            if address == openWallet.getAddress(index: n) {
                return n
            }
        }
        
        throw CoinWalletGeneralError.addressNotFound
    }

    func listAddresses() throws -> [String] {
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        var addressList: [String] = []
        
        for n in 0...(self.accounts - 1) {
            if let address = openWallet.getAddress(index: n) {
                addressList.append(address)
            }
        }
        
        return addressList
    }
    
    func getAddressByAccount(index: Int) throws -> String {
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        guard let address = openWallet.getAddress(index: index) else { throw CoinWalletGeneralError.accountDoesNotExist }
        
        return address
    }
    
    func getTotalBalance(includePending: Bool) throws -> Double {
        var totalBalance: Int64 = 0
        
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        
        for n in 0...(self.accounts - 1) {
            if (includePending) {
                totalBalance += openWallet.getVerifiedBalance(account: n)
            } else {
                totalBalance += openWallet.getBalance(account: n)
            }
        }
        
        return totalBalance.fromSats()
    }
    
    func getAccountBalance(includePending: Bool, accountIndex: Int) throws -> Double {
        guard let openWallet = wallet else { throw CoinWalletGeneralError.walletUnopened }
        
        if (includePending) {
            return openWallet.getBalance(account: accountIndex).fromSats()
        } else {
            return openWallet.getVerifiedBalance(account: accountIndex).fromSats()
        }
    }
}

struct SeedBox: SeedProvider {
  var _seed: [UInt8]
  func seed() -> [UInt8] {
    _seed
  }
  
  init(seedString: String) {
    _seed = Array(seedString.utf8)
  }
}

struct WalletSyncState {
    var percent: Float
    var height: Int
    var state: CompactBlockProcessor.State
}
