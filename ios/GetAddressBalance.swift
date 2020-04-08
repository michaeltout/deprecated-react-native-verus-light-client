//
//  ZGetBalance.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 20/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func getAddressBalance(wallet: CoinWallet, params: [String], id: Int?, completion: @escaping (Int?, Any?, RequestError?) ->()) {
    var includePending: Bool? = nil
    var searchAddress: String? = nil
    
    if params.count > 2 {
        return completion(id, nil, RequestError.badRequestParams(desc: "getbalance expected max 1 param, received " + String(params.count)))
    } else if params.count > 0 {
        searchAddress = params[0]
        
        if params.count > 1 {
            guard let pendingRequested = params[1].bool else {
                return completion(id, nil, RequestError.badRequestParams(desc: "getbalance expected boolean as second param, received " + String(describing: type(of: params[1]))))
            }
            
            includePending = pendingRequested
        }
    }
    
    do {
        return try completion(id, wallet.getAccountBalance(includePending: includePending ?? true, accountIndex: wallet.getAccountIndex(address: searchAddress!)), nil)
    } catch {
        return completion(id, nil, RequestError.internalError(error: error))
    }
}


