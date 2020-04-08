//
//  CoinKey.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

func getCoinKey(coinId: String, coinProtocol: String, accountHash: String) -> String {
    return coinId + "_" + coinProtocol + "_" + accountHash
}
