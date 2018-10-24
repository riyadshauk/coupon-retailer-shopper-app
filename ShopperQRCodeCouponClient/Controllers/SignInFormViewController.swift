//
//  ShopperLoginVC.swift
//  ShopperQRCodeCouponClient
//
//  Created by Riyad Shauk on 10/21/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

import Eureka

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
                    
                    executeSignInLogic(this: self, shopperEmail: shopperEmail, shopperPassword: shopperPassword)
                    
                    
                }
        }
    }
}
