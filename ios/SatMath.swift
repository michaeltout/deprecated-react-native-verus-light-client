//
//  SatMath.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 02/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import ZcashLightClientKit

extension Int64 {
    func fromSats() -> Double {
        Double(self) / Double(ZcashSDK.ZATOSHI_PER_ZEC)
    }
}

extension Double {
    func toSats() -> Int64 {
        Int64(self * Double(ZcashSDK.ZATOSHI_PER_ZEC))
    }
}
