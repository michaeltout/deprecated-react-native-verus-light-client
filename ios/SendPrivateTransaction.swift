//
//  SendPrivateTransaction.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 23/02/2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func sendPrivateTransaction(wallet: CoinWallet, params: [String], id: Int?, completion: @escaping (Int?, Any?, RequestError?) ->()) {
    var spendingKey: String
    var zatoshi: Int64
    var toAddress: String
    var memo: String = ""
    var fromAddress: String?
    var accountIndex: Int = 0
    
    if params.count > 5 {
        return completion(id, nil, RequestError.badRequestParams(desc: "sendprivatetransaction expected max 5 parameters, received " + String(params.count)))
    } else if params.count > 2 {
        guard let amount = Int64(params[0]) else {
            return completion(id, nil, RequestError.badRequestParams(desc: "sendprivatetransaction expected string representation of Int64 as first parameter, received '" + params[0] + "'"))
        }
        toAddress = params[1]
        zatoshi = amount
        spendingKey = params[2]
        
        if params.count > 3 {
            fromAddress = params[3]
        }
        
        if params.count > 4 {
            memo = params[4]
        }
    } else {
        return completion(id, nil, RequestError.badRequestParams(desc: "sendprivatetransaction expected at least 3 parameters, received " + String(params.count)))
    }
    
    do {
        let synchronizer = try wallet.getSynchronizer()
        var accountIndex: Int = 0
        
        if let fromAddressUnwrapped = fromAddress {
            accountIndex = try wallet.getAccountIndex(address: fromAddressUnwrapped)
        }
        
        synchronizer.sendToAddress(spendingKey: spendingKey, zatoshi: zatoshi, toAddress: toAddress, memo: memo.count > 0 ? memo : nil, from: accountIndex) {  result in
            
            switch result {
            case .success(let pendingTransaction):
                let txDict: [String: Any?] = [
                    "txid": pendingTransaction.rawTransactionId?.toHexStringTxId() ?? "",
                ]
                
                return completion(id, txDict, nil)
            case .failure(let error):
                return completion(id, nil, RequestError.internalError(error: error))
            }
        }
    } catch {
        return completion(id, nil, RequestError.internalError(error: error))
    }
}


