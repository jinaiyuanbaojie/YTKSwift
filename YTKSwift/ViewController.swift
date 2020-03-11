//
//  ViewController.swift
//  YTKSwift
//
//  Created by jinaiyuan on 2020/3/10.
//  Copyright © 2020 jinaiyuan. All rights reserved.
//

import UIKit
import Alamofire

struct TestData: Convertable {
    var data: String = "default"

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

class Request: HTTPRequest<TestData> {
    override var httpMethod: HTTPMethod {
        return .post
    }
    
    override var requestUrl: String {
        // return "/test"
        return "/test/singlevalue"
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let config = NetworkConfig()
        config.baseURL = "https://mobile-ms.uat.homecreditcfc.cn/mock/5c05d3ccf8c692001c64fb6c/SMT"
        NetworkAgent.sharedAgent.config = config
        NetworkAgent.sharedAgent.commonInit()
        
        Request().startRequest(httpSuccess: { data in
            let value: TestData = data
            print(value.data)
        }) { error in
            print(error)
        }
    }
}

