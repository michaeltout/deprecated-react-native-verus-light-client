//
//  AppConfig.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 28/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

struct AppConfig {
    static var host = ZcashSDK.isMainnet ? "lightwalletd.z.cash" : "lightwalletd.testnet.z.cash"
    static var port = 9067
    static var birthdayHeight: BlockHeight = ZcashSDK.isMainnet ? 643_500 : 620_000
    static var network = ZcashSDK.isMainnet ? ZcashNetwork.mainNet : ZcashNetwork.testNet
    static var seed = ZcashSDK.isMainnet ? Array("testreferencealice".utf8) : Array("testreferencealice".utf8)
    static var address: String {
        "\(host):\(port)"
    }
    
    /*static var processorConfig: CompactBlockProcessor.Configuration {
        var config = CompactBlockProcessor.Configuration(cacheDb: try! __cacheDbURL(), dataDb: try! __dataDbURL())
        config.walletBirthday = self.birthdayHeight
        return config
    }*/
    
    static var endpoint: LightWalletEndpoint {
        return LightWalletEndpoint(address: self.host, port: self.port, secure: true)
    }
}

enum ZcashNetwork {
    case mainNet
    case testNet
}
