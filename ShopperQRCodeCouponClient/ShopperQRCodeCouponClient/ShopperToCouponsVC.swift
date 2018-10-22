//
//  ViewController.swift
//  ShopperQRCodeCouponClient
//
//  Created by Riyad Shauk on 10/21/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

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
//let image = generateQRCode(from: "Hacking with Swift is the best iOS coding tutorial I've ever read!")

struct ShopperToCouponResponse: Decodable {
    var id: Int
    var shopperID: Int
    var couponID: Int
    var start: String
    var end: String
    // progress = some multiple of earningUnit divided by earningGoal
    var progress: Double
    // ie: "steps"
    var earningUnit: String
    // ie: 100 (for 100 steps)
    var earningGoal: Double
    var isValid: Bool
    // initially must be initialized to false
    var isRedeemed: Bool
    var product: String
    var name: String
    var title: String
    // if productDiscountPercentage < 0, it's invalid
    var productDiscountPercentage: Double
    // if productDiscount < 0, it's invalid
    var productDiscount: Double
    var timesProcessed: Int
}

var shopperToCouponResponse: [ShopperToCouponResponse] = []

class ShopperToCouponsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ShopperToCoupons"
        navigationController?.navigationBar.isTranslucent = false
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "ShopperToCoupons"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView.register(ShopperToCouponCell.self, forCellWithReuseIdentifier: "cellId")
        
        setNeedsStatusBarAppearanceUpdate()
        
        //        UIApplication.shared.statusBarStyle = .lightContent
        
        let getRelevantCouponsURL = URL(string: "http://b795f5fb.ngrok.io/relevantCoupons")!
        //                    let loginUrl = URL(string: "http://localhost:8080/retailerLogin")!
        
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
                    shopperToCouponResponse = try jsonDecoder.decode([ShopperToCouponResponse].self, from: data)
                    print("shopperToCouponResponse: \(shopperToCouponResponse)")
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "[ShopperToCouponResponse] Data loaded!",
                            message: dataString,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
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
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        task.resume()
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopperToCouponResponse.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ShopperToCouponCell
        
        cell.shopperToCoupon = shopperToCouponResponse[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 500)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // 0 eliminates extra spacing than specified in our padding constraints (setupViews)
    }
    
}

class ShopperToCouponCell: UICollectionViewCell {
    
    var shopperToCoupon: ShopperToCouponResponse? {
        didSet {
            titleLabel.text = "timesProcessed: \(shopperToCoupon?.timesProcessed ?? -1), title: \(shopperToCoupon?.title ?? "ERROR / title DNE")"
            
            thumbnailImageView.image = generateQRCode(from: "SHOPPERID\(shopperToCoupon?.shopperID ?? -1)SHOPPERTOCOUPONID\(shopperToCoupon?.id ?? -1)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
//        if !shopperToCouponResponse.isEmpty {
//            imageView.image = generateQRCode(from: "SHOPPERID\(shopperToCouponResponse[0].shopperID)SHOPPERTOCOUPONID\(shopperToCouponResponse[0].id)")
//        }
        imageView.contentMode = .scaleAspectFill // remove stretching from image
        imageView.clipsToBounds = true  // make sure image fits within view constraints
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ShopperToCoupon"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 5
        return label
    }()
    
    let subtitleTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Get outdoors! : )"
        textView.textColor = UIColor.lightGray
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        return textView
    }()
    
    func setupViews() {
        addSubview(thumbnailImageView)
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(subtitleTextView)
        
        // specify padding in pixels from horizontal axis
        addConstraintsWithFormat(format: "H:|-32-[v0(300)]-32-|", views: thumbnailImageView)
        addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: titleLabel)
        addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: subtitleTextView)
        
        // specify padding in pixels from vertical axis for v0
        // add v1 as separatorView that is 1 pixel tall, touching next edge/constraint
        addConstraintsWithFormat(format: "V:|-16-[v0(300)]-16-[v1(1)]|", views: thumbnailImageView, separatorView)
        // top constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: thumbnailImageView, attribute: .bottom, multiplier: 1, constant: 8))
        // top constraint
//        addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 4))
        // height constraint
//        addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 30))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView... /* array of UIView */) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false // allow custom constraints from code in setupViews
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
