//
//  SignInForm.swift
//  RetailerQRReader
//
//  Created by Riyad Shauk on 10/20/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

import Eureka

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

                    executeSignInLogic(this: self, retailerEmail: retailerEmail, retailerPassword: retailerPassword)


                }
        }
    }
}
