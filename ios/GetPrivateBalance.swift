//
//  GetBalance.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func getPrivateBalance(wallet: CoinWallet, params: [String], id: Int?, completion: @escaping (Int?, Any?, RequestError?) ->()) {
    if params.count > 0 {
        return completion(id, nil, RequestError.badRequestParams(desc: "getbalance expected 0 parameters, received " + String(params.count)))
    }
    
    do {
        return try completion(id, ["total": wallet.getTotalBalance(includePending: true), "confirmed": wallet.getTotalBalance(includePending: false)], nil)
    } catch {
        return completion(id, nil, RequestError.internalError(error: error))
    }
}

