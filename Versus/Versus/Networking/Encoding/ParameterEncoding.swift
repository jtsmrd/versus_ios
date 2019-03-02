//
//  ParameterEncoding.swift
//  Versus
//
//  Created by JT Smrdel on 1/6/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

typealias Parameters = [String: Any]

protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
