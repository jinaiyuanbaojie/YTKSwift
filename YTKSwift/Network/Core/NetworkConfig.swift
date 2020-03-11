//
//  NetworkConfig.swift
//  YTKSwift
//
//  Created by jinaiyuan on 2020/3/10.
//  Copyright © 2020 jinaiyuan. All rights reserved.
//

import Foundation
import Alamofire

public class NetworkConfig {
    public var sessionConfiguartion = URLSessionConfiguration.default
    public var serverTrustPolicyManager: ServerTrustPolicyManager?
    public var baseURL: String?
    
    public init() {
        sessionConfiguartion.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    }
}
