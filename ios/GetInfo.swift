//
//  GetInfo.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 13/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func getInfo(wallet: CoinWallet, params: [String], id: Int?, completion: @escaping (Int?, Any?, RequestError?) ->()) {
    guard params.count == 0 else {
        return completion(id, nil, RequestError.badRequestParams(desc: "getinfo expected no parameters, received " + String(params.count)))
    }
    
    do {
        let syncState = try wallet.getSyncState()
        
        let infoDict: [String: Any?] = [
            "percent": syncState.percent,
            "longestchain": syncState.height,
            "blocks": Int((Float(syncState.height) - Float(wallet.birthday)) * (syncState.percent/100)),
            "status": String(describing: syncState.state),
        ]
        
        return completion(id, infoDict, nil)
    } catch {
        return completion(id, nil, RequestError.internalError(error: error))
    }
}


