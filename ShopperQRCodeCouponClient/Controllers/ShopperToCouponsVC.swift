//
//  ViewController.swift
//  ShopperQRCodeCouponClient
//
//  Created by Riyad Shauk on 10/21/18.
//  Copyright © 2018 Riyad Shauk. All rights reserved.
//

import UIKit

var shopperToCouponResponse: [ShopperToCouponResponse] = []

// see following starter project/code: https://www.letsbuildthatapp.com/course_video?id=67
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
                
        getRelevantCoupons(this: self)
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
