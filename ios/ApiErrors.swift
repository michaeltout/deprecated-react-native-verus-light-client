//
//  ApiErrors.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

enum RequestError: Error {
    case badRequestMethod(method: String)
    case badRequestParams(desc: String)
    case badRequestCoin(coinId: String)
    case badRequestAccount(accountHash: String)
    case internalError(error: Error)
    case noResponse(id: Int?)
}

func translateError(error: RequestError) -> [String: Any?] {
    var description: String = "Unknown Error"
    var code: Int = JsonRpcErrors.GENERIC_ERROR
    var name: String = "Unknown Error"
    
    switch error {
    case .badRequestMethod(let method):
        code = JsonRpcErrors.INVALID_REQUEST
        description = method + " is not a valid method."
        name = "Invalid Request"
        break;
    case .badRequestParams(let desc):
        code = JsonRpcErrors.INVALID_PARAMS
        description = desc
        name = "Invalid Parameters"
        break;
    case .internalError(let errorInstance):
        code = JsonRpcErrors.INTERNAL_ERROR
        description = errorInstance.localizedDescription
        name = "Internal Error"
        break;
    case .noResponse(let id):
        code = JsonRpcErrors.NO_RESPONSE
        
        if id != nil {
            description = "No response or error received for call with ID " + String(id!)
        } else {
            description = "No response or error received for call with unknown ID"
        }
        
        name = "No Response"
        break;
    default:
        break;
    }
    
    return ["data": description, "code": code, "message": name]
}
