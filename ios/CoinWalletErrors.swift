//
//  CoinWalletErrors.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

enum CoinWalletGeneralError: Error {
    case walletUnopened
    case accountDoesNotExist
    case noSyncState
    case addressNotFound
}
