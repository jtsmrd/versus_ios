//
//  Router.swift
//  Versus
//
//  Created by JT Smrdel on 1/6/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

class Router<Endpoint: EndpointType>: NetworkRouter {
    
    private var task: URLSessionTask?
    
    
    func request(
        _ route: Endpoint,
        completion: @escaping NetworkRouterCompletion
    ) {
        
        let session = URLSession.shared
        
        do {
            let request = try buildRequest(from: route)
            
            task = session.dataTask(with: request, completionHandler: completion)
        }
        catch {
            completion(nil, nil, error)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.task?.resume()
        }
    }
    
    
    func cancel() {
        task?.cancel()
    }
    
    
    private func buildRequest(
        from route: Endpoint
    ) throws -> URLRequest {
        
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        
        do {
            switch route.task {
                
            case .request:
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            case .requestParameters(bodyParameters: let bodyParameters, urlParameters: let urlParameters):
                
                try configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
                
            case .requestParametersAndHeaders(bodyParameters: let bodyParameters, urlParameters: let urlParameters, additionalHeaders: let additionalHeaders):
                
                addAdditionalHeaders(additionalHeaders, request: &request)
                
                try configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
            }
            
            return request
        }
        catch {
            throw error
        }
    }
    
    
    private func configureParameters(
        bodyParameters: Parameters?,
        urlParameters: Parameters?,
        request: inout URLRequest
    ) throws {
        
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        }
        catch {
            throw error
        }
    }
    
    
    private func addAdditionalHeaders(
        _ additionalHeaders: HTTPHeaders?,
        request: inout URLRequest
    ) {
        
        guard let headers = additionalHeaders else { return }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
