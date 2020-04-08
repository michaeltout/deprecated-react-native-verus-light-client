//
//  DbUrlStructures.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 01/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

protocol WalletUrls {
    var cacheDb: URL { get }
    var dataDb: URL { get }
    var pendingDb: URL { get }
    var spendParams: URL { get }
    var outputParams: URL { get }
}

struct WalletFiles: WalletUrls {
    let cacheDb: URL
    let dataDb: URL
    let pendingDb: URL
    let spendParams: URL
    let outputParams: URL
}
