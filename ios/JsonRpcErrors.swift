//
//  JsonRpcErrors.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 28/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

struct JsonRpcErrors {
    static let INVALID_REQUEST = -32600
    static let GENERIC_ERROR = -1
    static let INTERNAL_ERROR = -32603
    static let INVALID_PARAMS = -32602
    static let NO_RESPONSE = -2
    static let ADD_WALLET_FAIL = -3
    static let START_SYNC_ERROR = -4
    static let STOP_SYNC_ERROR = -5
}

