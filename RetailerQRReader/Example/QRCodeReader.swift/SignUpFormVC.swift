//
//  SignUpForm.swift
//  QRCodeReader.swift
//
//  Created by Riyad Shauk on 10/20/18.
//  Copyright © 2018 Yannick Loriot. All rights reserved.
//

import Eureka

class SignUpFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Sign Up")
            <<< TextRow(){ row in
                row.title = "Retailer Name"
                row.add(rule: RuleRequired())
                row.placeholder = "retailer1"
            }
            <<< TextRow(){
                $0.title = "Retailer Email"
                $0.add(rule: RuleRequired())
                $0.placeholder = "retailer1@example.com"
            }
            <<< TextRow(){
                $0.title = "Retailer Password"
                $0.add(rule: RuleRequired())
                $0.placeholder = "123"
            }
            <<< TextRow(){
                $0.title = "Retailer Password (verification)"
                $0.add(rule: RuleRequired())
                $0.placeholder = "123"
            }
//            +++ Section("Section2")
//            <<< DateRow(){
//                $0.title = "Date Row"
//                $0.value = Date(timeIntervalSinceReferenceDate: 0)
//        }
    }
}
