//
//  ShopperToCouponCell.swift
//  ShopperQRCodeCouponClient
//
//  Created by Riyad Shauk on 10/23/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

import UIKit

// see following starter project/code: https://www.letsbuildthatapp.com/course_video?id=67
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
    
    func setupViews() {
        addSubview(thumbnailImageView)
        addSubview(separatorView)
        addSubview(titleLabel)
        
        // specify padding in pixels from horizontal axis
        addConstraintsWithFormat(format: "H:|-32-[v0(300)]-32-|", views: thumbnailImageView)
        addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: titleLabel)
        
        // specify padding in pixels from vertical axis for v0
        // add v1 as separatorView that is 1 pixel tall, touching next edge/constraint
        addConstraintsWithFormat(format: "V:|-16-[v0(300)]-16-[v1(1)]|", views: thumbnailImageView, separatorView)
        // top constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: thumbnailImageView, attribute: .bottom, multiplier: 1, constant: 8))
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
