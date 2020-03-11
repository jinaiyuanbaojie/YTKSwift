//
//  NetworkAgent.swift
//  YTKSwift
//
//  Created by jinaiyuan on 2020/3/10.
//  Copyright © 2020 jinaiyuan. All rights reserved.
//

import Foundation
import Alamofire

public enum NetworkAgentError: Error {
    case dataTaskInitializeFailed
}

public class NetworkAgent {
    /// this is the dafualt agent, you can also create your own agent if you have diff servers (diff baseUrls)
    public static let sharedAgent = NetworkAgent()
    
    // Using recursive lock for chase dead-lock away. Maybe it does not make sense here, but we should keep simple firstly.
    private let lock = NSRecursiveLock()
    private var sessionManager: SessionManager?
    public var config: NetworkConfig?
    private var requestRecord = [Int: BaseRequest]()
    
    /// You should call this method, after you set all the configrations, like baseurl, timeout, https policy
    public func commonInit() {
        guard let config = self.config else {
            assertionFailure("the property config:NetworkConfig is nil !!!")
            return
        }
        
        guard let _ = config.baseURL else {
            assertionFailure("the baseURL is nil !!!")
            return
        }
        
        sessionManager = SessionManager(configuration: config.sessionConfiguartion, serverTrustPolicyManager: config.serverTrustPolicyManager)
        sessionManager?.startRequestsImmediately = false
    }
    
    /// if you wanna start a request, you should call BaseRequest.start instead
    func addRequest(request: BaseRequest) {
        let url = buildReuqestURL(request: request)
        let dataTask = Alamofire.request(url, method: request.httpMethod, parameters: request.requestParameters, encoding: request.parameterEncoding, headers: request.requestHeaders).validate().responseJSON { response in
            switch response.result {
            case let .success(value):
                request.resposeData = value
                self.requestDidSuccessed(request: request)
            case let .failure(error):
                self.requesetDidFailed(request: request, error: error)
            }
            
            // clear records and blocks
            self.removeRequestToRecord(request: request)
            request.clearRequestCompletionBlock()
        }
        
        if let task = dataTask.task {
            request.requestTask = task
            addRequestToRecord(request: request)
            dataTask.resume()
        } else {
            // initialize failed
            requesetDidFailed(request: request, error: NetworkAgentError.dataTaskInitializeFailed)
        }
    }
    
    private func buildReuqestURL(request: BaseRequest) -> String {
        let detailURL = URL(string: request.requestUrl)
        assert(detailURL != nil , "Invalid reuqest sub url.")
        
        // if the url starts with "http"
        if let _ = detailURL?.scheme, let _ = detailURL?.host {
            return request.requestUrl
        }
        
        // too simple maybe
        return (config?.baseURL ?? "") + request.requestUrl
    }
    
    private func requestDidSuccessed(request: BaseRequest) {
        request.toggleAccessoriesWillStopCallBack()
        request.successCompletionBlock?(request)
        request.toggleAccessoriesDidStopCallBack()
    }
    
    private func requesetDidFailed(request: BaseRequest, error: Error) {
        request.error = error
        request.toggleAccessoriesWillStopCallBack()
        request.failureCompletionBlock?(request)
        request.toggleAccessoriesDidStopCallBack()
    }
    
    /// if you wanna cancel a request, you should call BaseRequest.stop instead
    func cancelRequest(request: BaseRequest) {
        request.requestTask?.cancel()
        removeRequestToRecord(request: request)
        request.clearRequestCompletionBlock()
    }
    
    public func cancelAllRequests() {
        lock.lock()
        defer {lock.unlock()}
        
        requestRecord.forEach { (_, request: BaseRequest) in
            request.stop()
        }
    }
    
    private func addRequestToRecord(request: BaseRequest) {
        guard let task = request.requestTask else {
            assertionFailure("The requestTask property of BaseRequest is nil")
            return
        }
        
        lock.lock()
        defer {lock.unlock()}
        
        requestRecord[task.taskIdentifier] = request
    }
    
    private func removeRequestToRecord(request: BaseRequest) {
        guard let task = request.requestTask else {
            assertionFailure("The requestTask property of BaseRequest is nil")
            return
        }
        
        lock.lock()
        defer {lock.unlock()}
        
        requestRecord.removeValue(forKey: task.taskIdentifier)
    }
}
