# YTKSwift
A swift version of YTKNetwork 

参考[YTKNetwork](https://github.com/yuantiku/YTKNetwork)并基于[Alamofire](https://github.com/Alamofire/Alamofire)封着的网络请求库

**Features**

1. 一个接口用一个类描述，改类只需要继承`HTTPRequest`
2. 无需担心block的循环引用，请求结束后会断开环形引用
3. JSON和Model的转化使用`Codable`

**TODO**

- Upload
- Download
- BatchRequest
- ChainRequest
- UnitTest
- Wiki Document
- Bug shoot