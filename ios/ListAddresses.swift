//
//  ListAddresses.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func listAddresses(wallet: CoinWallet, params: [String], id: Int?, completion: @escaping (Int?, Any?, RequestError?) ->()) {
    guard params.count == 0 else {
        return completion(id, nil, RequestError.badRequestParams(desc: "z_listaddresses expected no parameters, received " + String(params.count)))
    }
    
    do {
        return try completion(id, wallet.listAddresses(), nil)
    } catch {
        return completion(id, nil, RequestError.internalError(error: error))
    }
}

