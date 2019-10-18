//
//  HTTPTask.swift
//  Versus
//
//  Created by JT Smrdel on 1/6/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

typealias HTTPHeaders = [String: String]

enum HTTPTask {
    case request(additionalHeaders: HTTPHeaders?)
    case requestParameters(bodyParameters: Parameters?, urlParameters: Parameters?)
    case requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?, additionalHeaders: HTTPHeaders?)
}
