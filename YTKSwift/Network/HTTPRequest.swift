//
//  HTTPRequest.swift
//  YTKSwift
//
//  Created by jinaiyuan on 2020/3/11.
//  Copyright © 2020 jinaiyuan. All rights reserved.
//

import Foundation

public class LoadingRequesetAccessory: RequesetAccessory {
    public func requestWillStart(request: BaseRequest) {
        // show Loading
    }
    
    public func requestDidStop(request: BaseRequest) {
        // hide Loading
    }
}

public enum HTTPRequestError: Error {
    case convertModelFailure
    case unKnowError
}

/// This class is our business code should override normally. Added data cache feature
open class HTTPRequest<T: Convertable>: BaseRequest {
    
    public override init() {
        super.init()
        addRequestAccessory(requestAccessory: LoadingRequesetAccessory())
    }
    
    public func startRequest(httpSuccess: @escaping (_ data: T) -> Void, httpFailure: @escaping (_ error: Error) -> Void) {
        startWithBlock(success: { request in
            if let value = request.resposeData ,let model = T.convert(value: value) {
                httpSuccess(model)
            } else {
                httpFailure(HTTPRequestError.convertModelFailure)
            }
        }, failure: { request in
            httpFailure(request.error ?? HTTPRequestError.unKnowError)
        })
    }
}
