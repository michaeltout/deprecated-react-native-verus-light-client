//
//  JsonRpcResponse.swift
//  VerusLightClient
//
//  Created by Michael Filip Toutonghi on 28/02/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

public class JsonRpcResponse {
  var result: Any?
  var error: [String: Any?]?
  private var jsonRpcVersion: String
  private var id: Int?
  
  init(id: Int?, result: Any?, error: [String: Any?]?) {
    self.jsonRpcVersion = "2.0"
    self.id = id
    self.error = error
    self.result = result
  }
  
  func formatResponse() -> [String: Any?] {
    return ["result": self.result, "error": self.error, "id": self.id ?? nil, "jsonrpc": self.jsonRpcVersion]
  }
  
  func setError(code: Int, message: String, data: String?) -> Void {
    self.error = ["code": code, "message": message, "data": data ?? ""]
  }
}

