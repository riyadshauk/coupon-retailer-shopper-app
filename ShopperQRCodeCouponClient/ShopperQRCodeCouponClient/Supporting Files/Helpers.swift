//
//  Helpers.swift
//  ShopperQRCodeCouponClient
//
//  Created by Riyad Shauk on 10/23/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

var hostnameAndPort = "129.150.204.42" // "localhost:8080"

import UIKit

// see: https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code
func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        
        if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
        }
    }
    
    return nil
}

func getRelevantCoupons(this: ShopperToCouponsVC) {
    let getRelevantCouponsURL = URL(string: "http://\(hostnameAndPort)/relevantCoupons")!
    var request = URLRequest(url: getRelevantCouponsURL)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(shopperToken)", forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        print("Inside URLSession.shared.dataTask, attempting to get relevantCoupons")
        if let error = error {
            print("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse else {
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
                shopperToCouponResponse = try jsonDecoder.decode([ShopperToCouponResponse].self, from: data)
                print("shopperToCouponResponse: \(shopperToCouponResponse)")
                DispatchQueue.main.async {
                    this.collectionView.reloadData()
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "[ShopperToCouponResponse] Data loaded!",
                        message: dataString,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    this.present(alert, animated: true, completion: nil)
                }
            } catch {
                print("Error decoding ShopperToCouponResponse, actual response was: \(dataString)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Error: Could not parse [ShopperToCouponResponse]",
                        message: dataString,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    this.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    task.resume()
}

func executeSignInLogic(this: SignInFormViewController, shopperEmail: String, shopperPassword: String) {
    let loginRequest = ShopperLoginRequest(shopperEmail: shopperEmail, shopperPassword: shopperPassword)
    guard let uploadData = try? JSONEncoder().encode(loginRequest) else {
        return
    }
    let loginUrl = URL(string: "http://\(hostnameAndPort)/shopperLogin")!
    let loginString = "\(shopperEmail):\(shopperPassword)"
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
                let retailerLoginResponse = try jsonDecoder.decode(ShopperLoginResponse.self, from: data)
                shopperToken = retailerLoginResponse.string
                print("shopperToken: \(shopperToken)")
                DispatchQueue.main.async {
                    let layout = UICollectionViewFlowLayout()
                    this.navigationController?.pushViewController(ShopperToCouponsVC(collectionViewLayout: layout), animated: true)
                }
            } catch {
                print("Error decoding ShopperLoginResponse, actual response was: \(dataString)")
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
