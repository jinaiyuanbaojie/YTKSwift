//
//  BaseRequest.swift
//  YTKSwift
//
//  Created by jinaiyuan on 2020/3/10.
//  Copyright © 2020 jinaiyuan. All rights reserved.
//

import Foundation
import Alamofire

public typealias RequestHeaders = [String: String]
public typealias RequestParameters = [String: Any]

public protocol RequesetAccessory {
    func requestWillStart(request: BaseRequest)
    func requestWillStop(request: BaseRequest)
    func requestDidStop(request: BaseRequest)
}

/// default implemetions, so subclass need not implements all methods in protocol
extension RequesetAccessory {
    public func requestWillStart(request: BaseRequest) {}
    public func requestWillStop(request: BaseRequest) {}
    public func requestDidStop(request: BaseRequest) {}
}

public typealias RequestCompletionBlock = (_ request: BaseRequest) -> Void

open class BaseRequest {
    var successCompletionBlock: RequestCompletionBlock?
    var failureCompletionBlock: RequestCompletionBlock?
    private var requestAccessoryList = [RequesetAccessory]()

    internal(set) public var requestTask: URLSessionTask?
    internal(set) public var resposeData: Any?
    internal(set) public var error: Error?
    
    // MARK: Request and Response Information
    public var response: HTTPURLResponse? {
        if let httpResponse = requestTask?.response as? HTTPURLResponse {
            return httpResponse
        }
        
        return nil
    }
    
    public var responseStatusCode: Int {
        return response?.statusCode ?? -1
    }
    
    public var responseHeaders: [AnyHashable: Any]? {
        return response?.allHeaderFields
    }
    
    public var currentRequest: URLRequest? {
        return requestTask?.currentRequest
    }
    
    public var originalRequest: URLRequest? {
        return requestTask?.originalRequest
    }
    
    public var isCancelled: Bool {
        guard let currentTask = requestTask else {
            return false
        }
        
        return currentTask.state == .canceling
    }
    
    public var isExecuting: Bool {
        guard let currentTask = requestTask else {
            return false
        }
        
        return currentTask.state == .running
    }
    
    // MARK: Request lifecycles
    public func setRequestCompletionBlock(success: @escaping RequestCompletionBlock, failure: @escaping RequestCompletionBlock) {
        successCompletionBlock = success
        failureCompletionBlock = failure
    }
    
    public func clearRequestCompletionBlock() {
        successCompletionBlock = nil
        failureCompletionBlock = nil
    }
    
    public func addRequestAccessory(requestAccessory: RequesetAccessory) {
        requestAccessoryList.append(requestAccessory)
    }
    
    public func toggleAccessoriesWillStartCallBack() {
        requestAccessoryList.forEach { requestAccessory in
            requestAccessory.requestWillStart(request: self)
        }
    }
    
    public func toggleAccessoriesWillStopCallBack() {
        requestAccessoryList.forEach { requestAccessory in
            requestAccessory.requestWillStop(request: self)
        }
    }
    
    public func toggleAccessoriesDidStopCallBack() {
        requestAccessoryList.forEach { requestAccessory in
            requestAccessory.requestDidStop(request: self)
        }
    }
    
    // MARK: Request Actions
    public func start() {
        toggleAccessoriesWillStartCallBack()
        NetworkAgent.sharedAgent.addRequest(request: self)
    }
    
    public func stop() {
        toggleAccessoriesWillStopCallBack()
        NetworkAgent.sharedAgent.cancelRequest(request: self)
        toggleAccessoriesDidStopCallBack()
    }
    
    public func startWithBlock(success: @escaping RequestCompletionBlock, failure: @escaping RequestCompletionBlock) {
        setRequestCompletionBlock(success: success, failure: failure)
        start()
    }
    
    // MARK: Subclass override
    open var requestUrl: String {
        return ""
    }
    
    open var httpMethod: HTTPMethod {
        return .get
    }
    
    open var requestParameters: RequestParameters {
        return [:]
    }
    
    open var requestHeaders: RequestHeaders {
        return [:]
    }
    
    open var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
}

extension BaseRequest: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self))> { URL: \(currentRequest?.url?.absoluteString ?? "Undefined Url") } { method: \(currentRequest?.httpMethod ?? "Undefined HttpMethod") } { arguments: \(requestParameters) }"
    }
}

extension BaseRequest: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "<\(type(of: self))> { URL: \(currentRequest?.url?.absoluteString ?? "Undefined Url") } { method: \(currentRequest?.httpMethod ?? "Undefined HttpMethod") } { arguments: \(requestParameters) }"
    }
}
