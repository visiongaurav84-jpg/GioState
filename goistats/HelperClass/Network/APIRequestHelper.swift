//
//  APIRequestHelper.swift
//  USHA
//
//  Created by Hitesh Prajapati on 02/06/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD
import SystemConfiguration

//MARK: - Variables
enum ContentType : String {
    case applicationJson    =   "application/json"
    case applicationFormURL =   "application/x-www-form-urlencoded"
}

//MARK: -
class ApiRequestHelper{
    
    private static let serverTrustManager: ServerTrustManager = {
        return ServerTrustManager(evaluators: [
            "goistatsapp.mospi.gov.in": CompositeTrustEvaluator(evaluators: [
                PinnedCertificatesTrustEvaluator(),   // Certificate pinning
                PublicKeysTrustEvaluator()            // Public key pinning
            ])
        ])
    }()
    
    private static let pinnedSession: Session = {
        return Session(serverTrustManager: serverTrustManager)
    }()
    
    class func apiCall(url : String, parameters : NSDictionary?,
                       methodType : HTTPMethod, contentType : ContentType,
                       isRequireAuthorization : Bool,
                       checkSum : String,
                       encoding : ParameterEncoding = JSONEncoding.default,
                       showLoading : Bool,
                       success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                       failure: @escaping(_ error : Error, _ status : Int) -> Void){
        
        var salt = KeychainService.getIV() ?? ""
        
        let headers: [String: String]
        
        if isRequireAuthorization {
            var authHeaders: [String: String] = [
                "Salt": String(salt),
                "X-Requested-With": "XMLHttpRequest",
                "Accept": "application/json"
            ]
            
            if !checkSum.isEmpty {
                authHeaders["CheckSum"] = checkSum
            }
            
            headers = authHeaders
        } else {
            headers = ["Accept": contentType.rawValue]
        }
        
        print(headers)
        if showLoading{
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setBackgroundColor(UIColor.textColorOneBlueToYellow)
            SVProgressHUD.setForegroundColor(UIColor.textColorSixWhiteToBlack)
            SVProgressHUD.setRingRadius(10)                 // Spinner radius
            SVProgressHUD.setRingThickness(1.5)             // Spinner thickness
            SVProgressHUD.setFont(.systemFont(ofSize: 12))  // Status label font
            SVProgressHUD.setMinimumSize(CGSize(width: 5, height: 5)) // Force size
            SVProgressHUD.setContainerView(nil) // ensure not overridden
            SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
            SVProgressHUD.show(withStatus: "Getting things ready for you...")
        }
        
        //URLEncoding() as ParameterEncoding
        pinnedSession.request(url, method: methodType, parameters: parameters as? [String: Any], encoding: JSONEncoding.default, headers: HTTPHeaders(headers))
            .validate()
            .responseData { response in
                
                //print(response)
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let data):
                    do {
                        // Keep original JSON string as-is
                        if let jsonString = String(data: data, encoding: .utf8) {
                            //print("Server Response (Raw JSON):\n\(jsonString)")
                            
                            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                success(jsonObject, response.response?.statusCode ?? 0)
                            } else {
                                failure(
                                    NSError(
                                        domain: "",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"]
                                    ),
                                    response.response?.statusCode ?? 0
                                )
                            }
                        } else {
                            failure(
                                NSError(
                                    domain: "",
                                    code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Unable to convert response to string"]
                                ),
                                response.response?.statusCode ?? 0
                            )
                        }
                    } catch {
                        failure(error, response.response?.statusCode ?? 0)
                    }
                    
                case .failure(let error):
                    failure(error, response.response?.statusCode ?? 0)
                }
            }
        
    }
    
    
    static func apiSuperVisorRfcImageUpdate(
        img: String,
        sig: String,
        images: [UIImage],
        photoParamName: [String],
        url: String,
        methodType: HTTPMethod,
        requireAuthorisation: Bool,
        parameters: [String: Any]?,
        success: @escaping (_ response: NSDictionary, _ status: Int) -> Void,
        failure: @escaping (_ error: Error, _ status: Int) -> Void,
        progressHandler: @escaping (_ progress: Double) -> Void
    ) {
        SVProgressHUD.show()
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        if requireAuthorisation {
            headers["Authorization"] = "Bearer \(Constant.AccessToken)"
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            // Append images
            for (index, image) in images.enumerated() {
                let paramName = (index == 4) ? sig : img
                if let imgData = image.jpegData(compressionQuality: 0.4) {
                    multipartFormData.append(imgData, withName: paramName, fileName: photoParamName[index], mimeType: "image/jpeg")
                }
            }
            
            // Append parameters
            if let params = parameters {
                for (key, value) in params {
                    if let stringValue = value as? String {
                        multipartFormData.append(Data(stringValue.utf8), withName: key)
                    } else if let intValue = value as? Int {
                        multipartFormData.append(Data("\(intValue)".utf8), withName: key)
                    } else if let arrayValue = value as? [Any] {
                        for element in arrayValue {
                            let arrayKey = "\(key)[]"
                            let elementData = Data("\(element)".utf8)
                            multipartFormData.append(elementData, withName: arrayKey)
                        }
                    }
                }
            }
        }, to: encodedUrl, method: methodType, headers: headers)
        .uploadProgress { progress in
            progressHandler(progress.fractionCompleted)
        }
        .responseData { response in
            SVProgressHUD.dismiss()
            switch response.result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        success(json, response.response?.statusCode ?? 0)
                    } else {
                        failure(NSError(domain: "Invalid JSON", code: -1, userInfo: nil), response.response?.statusCode ?? 0)
                    }
                } catch {
                    failure(error, response.response?.statusCode ?? 0)
                }
                
            case .failure(let error):
                failure(error, response.response?.statusCode ?? 0)
            }
        }
    }
    
    static func apiMultipalImageUpdate(
        owner: String,
        customer: String,
        images: [UIImage],
        photoParamName: [String],
        url: String,
        methodType: HTTPMethod,
        requireAuthorisation: Bool,
        parameters: [String: Any]?,
        success: @escaping (_ response: NSDictionary, _ status: Int) -> Void,
        failure: @escaping (_ error: Error, _ status: Int) -> Void,
        progressHandler: @escaping (_ progress: Double) -> Void
    ) {
        SVProgressHUD.show()
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        AF.upload(
            multipartFormData: { multipartFormData in
                for (index, image) in images.enumerated() {
                    if let imgData = image.jpegData(compressionQuality: 0.4) {
                        let fieldName = (index == 0) ? customer : owner
                        let fileName = photoParamName[index]
                        multipartFormData.append(imgData, withName: fieldName, fileName: fileName, mimeType: "image/jpeg")
                    }
                }
                
                if let params = parameters {
                    for (key, value) in params {
                        if let stringValue = value as? String {
                            multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                        } else if let intValue = value as? Int {
                            multipartFormData.append("\(intValue)".data(using: .utf8)!, withName: key)
                        } else if let arrayValue = value as? NSArray {
                            arrayValue.forEach { element in
                                let keyObj = key + "[]"
                                let valueStr = "\(element)"
                                multipartFormData.append(valueStr.data(using: .utf8)!, withName: keyObj)
                            }
                        }
                    }
                }
            },
            to: encodedUrl,
            method: methodType,
            headers: {
                var headers: HTTPHeaders = [
                    "Content-Type": "application/json"
                ]
                if requireAuthorisation {
                    headers.add(name: "Authorization", value: "Bearer \(Constant.AccessToken)")
                }
                return headers
            }()
        )
        .uploadProgress { progress in
            progressHandler(progress.fractionCompleted)
        }
        .responseData { response in
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let data):
                do {
                    // Manually parse JSON
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        success(jsonObject, response.response?.statusCode ?? 0)
                    } else {
                        failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil), response.response?.statusCode ?? 0)
                    }
                } catch {
                    failure(error, response.response?.statusCode ?? 0)
                }
            case .failure(let error):
                failure(error, response.response?.statusCode ?? 0)
            }
        }
    }
    
    
    static func apiImageUpdate(imageName: String, images: [UIImage], photoParamName: [String], url: String, methodType: HTTPMethod,
                               requireAuthorisation: Bool,
                               parameters: [String: Any]?,
                               success: @escaping (_ response: NSDictionary, _ status: Int) -> Void,
                               failure: @escaping (_ error: Error, _ status: Int) -> Void,
                               progressHandler: @escaping (_ progress: Double) -> ()) {
        
        SVProgressHUD.show()
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var headers: HTTPHeaders = ["Content-Type": "multipart/form-data"]
        if requireAuthorisation {
            headers["Authorization"] = "Bearer \(Constant.AccessToken)"
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            if !images.isEmpty {
                for (index, image) in images.enumerated() {
                    if let imgData = image.jpegData(compressionQuality: 0.4) {
                        multipartFormData.append(imgData, withName: imageName, fileName: photoParamName[index], mimeType: "image/jpeg")
                    }
                }
            }
            
            if let params = parameters {
                for (key, value) in params {
                    if let temp = value as? String {
                        multipartFormData.append(Data(temp.utf8), withName: key)
                    } else if let temp = value as? Int {
                        multipartFormData.append(Data("\(temp)".utf8), withName: key)
                    } else if let temp = value as? NSArray {
                        temp.forEach { element in
                            let keyObj = key + "[]"
                            let value = "\(element)"
                            multipartFormData.append(Data(value.utf8), withName: keyObj)
                        }
                    }
                }
            }
        }, to: encodedUrl, method: methodType, headers: headers)
        .uploadProgress { progress in
            progressHandler(progress.fractionCompleted)
        }
        .responseData { response in
            SVProgressHUD.dismiss()
            
            switch response.result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        success(json, response.response?.statusCode ?? 0)
                    } else if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                        success(["Data": jsonArray], response.response?.statusCode ?? 0)
                    } else {
                        failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil), response.response?.statusCode ?? 0)
                    }
                } catch {
                    failure(error, response.response?.statusCode ?? 0)
                }
                
            case .failure(let error):
                failure(error, response.response?.statusCode ?? 0)
            }
        }
    }
    
    
    static func apiCall(images: [UIImage], photoParamName: [String], url: String, methodType: HTTPMethod,
                        requireAuthorisation: Bool,
                        parameters: [String: Any]?,
                        success: @escaping (_ response: NSDictionary, _ status: Int) -> Void,
                        failure: @escaping (_ error: Error, _ status: Int) -> Void,
                        progressHandler: @escaping (_ progress: Double) -> ()) {
        
        SVProgressHUD.show()
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        AF.upload(multipartFormData: { multipartFormData in
            for i in 0..<images.count {
                if let imgData = images[i].jpegData(compressionQuality: 0.4) {
                    multipartFormData.append(imgData, withName: i == 0 ? "PhotoFile" : "SignatureFile", fileName: photoParamName[i], mimeType: "image/jpeg")
                }
            }
            if let params = parameters {
                for (key, value) in params {
                    if let temp = value as? String {
                        multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    } else if let temp = value as? Int {
                        multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    } else if let temp = value as? NSArray {
                        temp.forEach({ element in
                            let keyObj = key + "[]"
                            if let string = element as? String {
                                multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                            } else {
                                let value = "\(element)"
                                multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                            }
                        })
                    }
                }
            }
        }, to: encodedUrl, method: methodType, headers: requireAuthorisation ? ["Authorization": "Bearer \(Constant.AccessToken)"] : nil)
        .uploadProgress { progress in
            progressHandler(progress.fractionCompleted)
        }
        .responseData { response in
            SVProgressHUD.dismiss()
            switch response.result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        success(jsonObject, response.response?.statusCode ?? 0)
                    } else {
                        let error = NSError(domain: "InvalidData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
                        failure(error, response.response?.statusCode ?? 0)
                    }
                } catch {
                    failure(error, response.response?.statusCode ?? 0)
                }
            case .failure(let error):
                failure(error, response.response?.statusCode ?? 0)
            }
        }
    }
    
    static func apiCall2(images: [UIImage], photoParamName: [String], url: String, methodType: HTTPMethod,
                         requireAuthorisation: Bool,
                         parameters: [String: Any]?,
                         success: @escaping (_ response: NSDictionary, _ status: Int) -> Void,
                         failure: @escaping (_ error: Error, _ status: Int) -> Void,
                         progressHandler: @escaping (_ progress: Double) -> ()) {
        
        SVProgressHUD.show()
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data"
        ]
        
        if requireAuthorisation {
            headers["Authorization"] = "Bearer \(Constant.AccessToken)"
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for i in 0..<images.count {
                if let imgData = images[i].jpegData(compressionQuality: 0.4) {
                    multipartFormData.append(imgData, withName: "DependentImg", fileName: photoParamName[i], mimeType: "image/jpeg")
                }
            }
            
            if let params = parameters {
                for (key, value) in params {
                    if let temp = value as? String {
                        multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    } else if let temp = value as? Int {
                        multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    } else if let temp = value as? NSArray {
                        temp.forEach { element in
                            let keyObj = key + "[]"
                            let value = "\(element)"
                            multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    }
                }
            }
        }, to: encodedUrl, method: methodType, headers: headers)
        .uploadProgress { progress in
            progressHandler(progress.fractionCompleted)
        }
        .responseData { response in
            SVProgressHUD.dismiss()
            switch response.result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        success(jsonObject, response.response?.statusCode ?? 0)
                    } else if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                        success(["Data": jsonArray], response.response?.statusCode ?? 0)
                    } else {
                        failure(NSError(domain: "Invalid JSON format", code: -1, userInfo: nil), response.response?.statusCode ?? 0)
                    }
                } catch {
                    failure(error, response.response?.statusCode ?? 0)
                }
                
            case .failure(let error):
                failure(error, response.response?.statusCode ?? 0)
            }
        }
    }
}

class ApiRequest{
    
    //MARK: - Authentication
    class func authHandShakeAPI(params : NSDictionary, checkSum : String,
                                success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                failure: @escaping(_ error : Error, _ status : Int) -> Void){
       // print(ApiUrl.authHandshakeAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.authHandshakeAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func topProductsAPI(params : NSDictionary, checkSum : String,
                              success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                              failure: @escaping(_ error : Error, _ status : Int) -> Void){
       // print(ApiUrl.topProductsAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.topProductsAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func indicatorListingAPI(params : NSDictionary, checkSum : String,
                                   success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                   failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.productsListAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.productsListAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func infographicsAPI(params : NSDictionary, checkSum : String,
                               success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                               failure: @escaping(_ error : Error, _ status : Int) -> Void){
       // print(ApiUrl.infographicsAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.infographicsAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    
    class func productDetailsAPI(params : NSDictionary, checkSum : String,
                                 success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                 failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.productDetailsAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.productDetailsAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func searchAPI(params : NSDictionary, checkSum : String,
                         success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                         failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.searchAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.searchAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func infographicsDetailsAPI(params : NSDictionary, checkSum : String,
                                      success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                      failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.infoGraphicDetailsAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.infoGraphicDetailsAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    
    class func updateViewAPI(params : NSDictionary, checkSum : String,
                             success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                             failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.updateViewAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.updateViewAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    
    class func aboutUsAPI(params : NSDictionary, checkSum : String,
                          success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                          failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.aboutUsAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.aboutUsAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    
    class func reportsListingAPIAPI(params : NSDictionary, checkSum : String,
                                    success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                    failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.reportsListingAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.reportsListingAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    
    class func whatsNewAPI(params : NSDictionary, checkSum : String,
                           success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                           failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.whatsNewAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.whatsNewAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func advanceReleaseAPI(params : NSDictionary, checkSum : String,
                                 success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                 failure: @escaping(_ error : Error, _ status : Int) -> Void){
       // print(ApiUrl.advanceReleaseAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.advanceReleaseAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func contactUsAPI(params : NSDictionary, checkSum : String,
                            success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                            failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.contactUsAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.contactUsAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func getNotificationAPI(params : NSDictionary, checkSum : String,
                                  success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                  failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.notificationAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.notificationAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: false, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    class func submitFeedbackAPI(params : NSDictionary, checkSum : String,
                                 success: @escaping(_ response : NSDictionary, _ status : Int) -> Void,
                                 failure: @escaping(_ error : Error, _ status : Int) -> Void){
        //print(ApiUrl.submitFeedbackAPI)
        ApiRequestHelper.apiCall(url: ApiUrl.submitFeedbackAPI, parameters: params, methodType: .post, contentType: .applicationJson, isRequireAuthorization: true,checkSum: checkSum, showLoading: true, success: { (response, status) in
            success(response, status)
        }) { (error, status) in
            failure(error, status)
        }
    }
    
    
    
    
}
