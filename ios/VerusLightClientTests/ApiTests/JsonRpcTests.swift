//
//  JsonRpcTests.swift
//  VerusLightClientTests
//
//  Created by Michael Filip Toutonghi on 01/03/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import XCTest
@testable import VerusLightClient

class JsonRpcTests: XCTestCase {
    func testCreateJsonRpcSuccess() {
        let testSuccessReponse = JsonRpcResponse(id: 1, result: "result", error: nil).formatResponse()
        
        XCTAssertEqual(testSuccessReponse["id"] as! Int, 1)
        XCTAssertEqual(testSuccessReponse["result"] as! String, "result")
        XCTAssertEqual(testSuccessReponse["jsonrpc"] as! String, "2.0")
        XCTAssertNil(testSuccessReponse["error"] ?? nil)
    }
    
    func testCreateJsonRpcError() {
        let testErrorReponse = JsonRpcResponse(id: 1, result: "result", error: nil)
        testErrorReponse.setError(code: JsonRpcErrors.GENERIC_ERROR, message: "Error", data: "GeneralError")
        
        let testErrorResponseFormatted = testErrorReponse.formatResponse()
        let errorDict = testErrorResponseFormatted["error"] as! [String: Any?]
        
        XCTAssertEqual(errorDict["code"] as! Int, JsonRpcErrors.GENERIC_ERROR)
        XCTAssertEqual(errorDict["message"] as! String, "Error")
        XCTAssertEqual(errorDict["data"] as! String, "GeneralError")
    }
}
