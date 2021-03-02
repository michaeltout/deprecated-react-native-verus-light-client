//
//  GetBlockCount.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 28/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

func getBlockCount(wallet: CoinWallet, params: [String], id: Int?, completion: @escaping (Int?, Any?, RequestError?) ->()) {
    do {
        let service: LightWalletService = try wallet.getService()
        guard params.count == 0 else {
            return completion(id, nil, RequestError.badRequestParams(desc: "getblockcount expected no parameters, received " + String(params.count)))
        }

        service.latestBlockHeight { (result) in
            switch result {
            case .success(let height):
                //print(height)
                //print(service)
                return completion(id, height, nil)
            case .failure(let error):
                return completion(id, nil, RequestError.internalError(error: error))
            }
        }
    } catch {
        return completion(id, nil, RequestError.internalError(error: error))
    }
}
