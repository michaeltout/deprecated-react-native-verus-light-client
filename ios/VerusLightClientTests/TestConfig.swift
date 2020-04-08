//
//  TestConfig.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 28/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

struct TestConfig {
    static var accountHash = "abcde12345"
    static var seed = "a seed that is at least 32 bytes long so that it will work with the ZIP 32 protocol."
    
    struct ZecConfig {
        static var coinId = "ZEC"
        static var coinProto = "btc"
        static var address = "lightwalletd.testnet.z.cash"
        static var port = 9067
    }
    
    struct VrscConfig {
        static var coinId = "VRSC"
        static var coinProto = "vrsc"
        static var address = "207.254.46.108.nip.io"
        static var port = 9077
    }
}

func getSaplingParams(testBundle: Bundle) -> [String: URL]{
    return ["spend": testBundle.url(forResource: "sapling-spend", withExtension: ".params")!, "output": testBundle.url(forResource: "sapling-output", withExtension: ".params")!]
}
