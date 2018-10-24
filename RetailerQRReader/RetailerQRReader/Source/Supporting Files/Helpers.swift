//
//  Helpers.swift
//  RetailerQRReader
//
//  Created by Riyad Shauk on 10/23/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

import UIKit

var hostnameAndPort = "129.150.204.42" // "localhost:8080"

// see: https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func executeSignInLogic(this: SignInFormViewController, retailerEmail: String, retailerPassword: String) {
    let loginRequest = RetailerLoginRequest(retailerEmail: retailerEmail, retailerPassword: retailerPassword)
    guard let uploadData = try? JSONEncoder().encode(loginRequest) else {
        return
    }
    let loginUrl = URL(string: "http://\(hostnameAndPort)/retailerLogin")!
    let loginString = "\(retailerEmail):\(retailerPassword)"
    
    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()
    var request = URLRequest(url: loginUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse
            else {
                print("server error")
                return
        }
        var dataString = ""
        if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
            dataString = String(data: data, encoding: .utf8) ?? ""
        }
        if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
            let jsonDecoder = JSONDecoder()
            do {
                let retailerLoginResponse = try jsonDecoder.decode(RetailerLoginResponse.self, from: data)
                retailerToken = retailerLoginResponse.string
                print("retailerToken: \(retailerToken)")
                DispatchQueue.main.async {
                    if let otherVC = this.storyboard?.instantiateViewController(withIdentifier: "ScannerVC") as? QRScannerViewController {
                        this.navigationController?.pushViewController(otherVC, animated: true)
                    }
                }
            } catch {
                print("Error decoding RetailerLoginResponse, actual response was: \(dataString)")
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "Error: Incorrect Credentials", message: dataString, preferredStyle: UIAlertController.Style.alert)
                    errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel))
                    this.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
    task.resume()
}

func executeScanningLogic(this: QRScannerViewController, s: String) {
    let matched = matches(for: "[0-9]+", in: s)
    var processCouponRequest: ProcessCouponRequest
    if matched.count == 2 {
        processCouponRequest = ProcessCouponRequest(shopperID: Int(matched[0]) ?? -1, shopperToCouponID: Int(matched[1]) ?? -1)
    } else {
        print("Error matching regex for shopperID and shopperToCouponID integers.")
        return
    }
    guard let uploadData = try? JSONEncoder().encode(processCouponRequest) else {
        return
    }
    let loginUrl = URL(string: "http://\(hostnameAndPort)/processCoupon")!
    var request = URLRequest(url: loginUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(retailerToken)", forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse
            else {
                print("server error")
                return
        }
        var dataString = ""
        if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
            dataString = String(data: data, encoding: .utf8) ?? ""
        }
        if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
            let jsonDecoder = JSONDecoder()
            do {
                let processCouponResponse = try jsonDecoder.decode(ProcessCouponResponse.self, from: data)
                print("timesProcessed: \(processCouponResponse.timesProcessed)")
                DispatchQueue.main.async {
                    this.dismiss(animated: true) { [weak this] in
                        let alert = UIAlertController(
                            title: "Coupon Processed!",
                            message: dataString,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        this?.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("Error decoding ProcessCouponResponse, actual response was: \(dataString)")
                DispatchQueue.main.async {
                    this.dismiss(animated: true) { [weak this] in
                        let alert = UIAlertController(
                            title: "Error: Invalid QR Code",
                            message: dataString,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        this?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    task.resume()
}
