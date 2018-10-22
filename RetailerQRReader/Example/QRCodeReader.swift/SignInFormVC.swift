//
//  SignInForm.swift
//  QRCodeReader.swift
//
//  Created by Riyad Shauk on 10/20/18.
//  Copyright © 2018 Yannick Loriot. All rights reserved.
//

import Eureka

struct RetailerLoginRequest: Encodable {
    let retailerEmail: String
    let retailerPassword: String
}
struct RetailerLoginResponse: Decodable {
    var id: Int
    var string: String
    var retailerID: Int
    var expiresAt: String
}
var retailerToken = ""

class SignInFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Retailer Sign In"
        var retailerEmail = ""
        var retailerPassword = ""
        form +++ Section("Sign In")
            <<< TextRow(){ row in
                row.title = "Retailer Email"
                row.add(rule: RuleRequired())
                row.placeholder = "retailer1@example.com"
                row.onChange({ (textRow: TextRow) in
                    retailerEmail = textRow.value ?? ""
                    if retailerEmail == "" {
                        retailerEmail = row.placeholder!
                    }
                })
                retailerEmail = row.placeholder!
            }
            <<< TextRow(){ row in
                row.title = "Retailer Password"
                row.add(rule: RuleRequired())
                row.placeholder = "123"
                row.onChange({ (textRow: TextRow) in
                    retailerPassword = textRow.value ?? ""
                    if retailerPassword == "" {
                        retailerPassword = row.placeholder!
                    }
                })
                retailerPassword = row.placeholder!
            }
            <<< ButtonRow() {
                $0.title = "Sign In"
                $0.onCellSelection() { (buttonCellOf: ButtonCellOf<String>, buttonRow: ButtonRow) in
                    
                    let loginRequest = RetailerLoginRequest(retailerEmail: retailerEmail, retailerPassword: retailerPassword)
                    guard let uploadData = try? JSONEncoder().encode(loginRequest) else {
                        return
                    }
                    
                    let loginUrl = URL(string: "http://b795f5fb.ngrok.io/retailerLogin")!
//                    let loginUrl = URL(string: "http://localhost:8080/retailerLogin")!
                    
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
                            //                            , (200...299).contains(response.statusCode)
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
                                    if let otherVC = self.storyboard?.instantiateViewController(withIdentifier: "ScannerVC") as? QRScannerViewController {
                                        self.navigationController?.pushViewController(otherVC, animated: true)
                                    }
                                }
                            } catch {
                                print("Error decoding RetailerLoginResponse, actual response was: \(dataString)")
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
