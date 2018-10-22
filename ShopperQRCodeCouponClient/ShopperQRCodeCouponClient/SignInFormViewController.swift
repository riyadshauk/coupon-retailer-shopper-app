//
//  ShopperLoginVC.swift
//  ShopperQRCodeCouponClient
//
//  Created by Riyad Shauk on 10/21/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

import Eureka

struct ShopperLoginRequest: Encodable {
    let shopperEmail: String
    let shopperPassword: String
}
struct ShopperLoginResponse: Decodable {
    var id: Int
    var string: String
    var shopperID: Int
    var expiresAt: String
}
var shopperToken = ""

class SignInFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Shopper Sign In"
        var shopperEmail = ""
        var shopperPassword = ""
        form +++ Section("Sign In")
            <<< TextRow(){ row in
                row.title = "Shopper Email"
                row.add(rule: RuleRequired())
                row.placeholder = "shopper1@example.com"
                row.onChange({ (textRow: TextRow) in
                    shopperEmail = textRow.value ?? ""
                    if shopperEmail == "" {
                        shopperEmail = row.placeholder!
                    }
                })
                shopperEmail = row.placeholder!
            }
            <<< TextRow(){ row in
                row.title = "Shopper Password"
                row.add(rule: RuleRequired())
                row.placeholder = "123"
                row.onChange({ (textRow: TextRow) in
                    shopperPassword = textRow.value ?? ""
                    if shopperPassword == "" {
                        shopperPassword = row.placeholder!
                    }
                })
                shopperPassword = row.placeholder!
            }
            <<< ButtonRow() {
                $0.title = "Sign In"
                $0.onCellSelection() { (buttonCellOf: ButtonCellOf<String>, buttonRow: ButtonRow) in
                    
                    let loginRequest = ShopperLoginRequest(shopperEmail: shopperEmail, shopperPassword: shopperPassword)
                    guard let uploadData = try? JSONEncoder().encode(loginRequest) else {
                        return
                    }
                    
                    let loginUrl = URL(string: "http://b795f5fb.ngrok.io/shopperLogin")!
                    //                    let loginUrl = URL(string: "http://localhost:8080/retailerLogin")!
                    
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
                                    self.navigationController?.pushViewController(ShopperToCouponsVC(collectionViewLayout: layout), animated: true)
                                }
                            } catch {
                                print("Error decoding ShopperLoginResponse, actual response was: \(dataString)")
                                DispatchQueue.main.async {
                                    let errorAlert = UIAlertController(title: "Error: Incorrect Credentials", message: dataString, preferredStyle: UIAlertController.Style.alert)
                                    errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel))
                                    self.present(errorAlert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    
                    task.resume()
                    
                    
                }
        }
    }
}
