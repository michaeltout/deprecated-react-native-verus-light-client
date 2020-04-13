//
//  TransactionProtocols.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 21/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

typealias TransactionJson = [String: Any?]

class CompactTransaction {
  var address: String?
  var amount: Double // Not represented in satoshis/zatoshis
  var category: String?
  var status: String?
  var time: TimeInterval?
  var txid: String
  var height: Int
  
  init(address: String?, amount: Double, dbType: String, time: TimeInterval?, txid: String, height: Int, localAddrs: [String]) {
    self.address = address
    self.amount = amount
    self.category = "unknown"
    self.status = "unknown"
    self.height = height
    self.txid = txid
    self.time = time
    
    switch dbType {
    case "received":
      self.category = "received"
      self.status = "confirmed"
      break;
    case "sent":
      self.category = "sent"
      self.status = "confirmed"
      break;
    case "pending",
         "cleared":
      if dbType == "pending" {
        self.status = "pending"
      } else {
        self.status = "cleared"
      }
      
      if address != nil && localAddrs.contains(address!) {
        self.category = "received"
        break;
      }
      
      self.category = "sent"
      break;
    default:
      break;
    }
  }
  
  func toJson() -> TransactionJson {
    return [
      "address": self.address,
      "amount": self.amount,
      "category": self.category,
      "status": self.status,
      "time": self.time,
      "txid": self.txid,
      "height": self.height,
    ]
  }
}
