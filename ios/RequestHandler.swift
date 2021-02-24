//
//  RequestHandler.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 28/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func handleJsRequest(wallet: CoinWallet, id: Int?, method: String?, params: [String]?, completion: @escaping (Int?, Any?, RequestError?) -> ()) {
    var chainCall: ((_ wallet: CoinWallet, _ params: [String], _ id: Int?, _ completion: @escaping (Int?, Any?, RequestError?)->()) -> ())? = nil

    switch method {
        case "getblockcount":
            chainCall = getBlockCount
            break;
        case "listaddresses",
             "z_listaddresses":
            chainCall = listAddresses
            break;
        case "getprivatebalance":
            chainCall = getPrivateBalance
            break;
        case "sendprivatetransaction":
            chainCall = sendPrivateTransaction
            break;
        case "z_getbalance",
             "getaddressbalance":
            chainCall = getAddressBalance
            break;
        case "listprivatetransactions":
            chainCall = listZTransactions
            break;
        case "getinfo":
            chainCall = getInfo
            break;
        default:
            break;
    }

    guard chainCall != nil else {
        return completion(id, nil, RequestError.badRequestMethod(method: method ?? "null"))
    }

    return chainCall!(wallet, params ?? [], id, completion)
}

func formatApiResponse(id: Int?, result: Any?, error: RequestError?) -> [String: Any?] {
    if result != nil {
        return JsonRpcResponse(id: id, result: result, error: nil).formatResponse()
    } else if error != nil {
        return JsonRpcResponse(id: id, result: nil, error: translateError(error: error!)).formatResponse()
    } else {
        return JsonRpcResponse(id: id, result: nil, error: translateError(error: RequestError.noResponse(id: id))).formatResponse()
    }
}
