//
//  ViewController.swift
//  BWCycleScrollView
//
//  Created by test on 2019/3/28.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var bannerView:BWCycleScrollView!
    let screenWidth = UIScreen.main.bounds.width
    let height:CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let imgUrl = ["https://upload-images.jianshu.io/upload_images/4014747-753b98eef55ec86b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/580",
                      "https://upload-images.jianshu.io/upload_images/4014747-7bf9bb38e9e9bbf1.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000",
            "https://upload-images.jianshu.io/upload_images/16080671-66d3e97d77d7d8a5.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/399",
            "https://upload-images.jianshu.io/upload_images/13737711-f9adb1d803925d12.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000"
                      ]
//        let imgUrl = ["image_1","image_2","image_3","image_4"]
        let titleArray = ["test1", "test2", "test3", "test4"]
        
        bannerView = BWCycleScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: height), scrollViewWidth: screenWidth, scrollViewHeight: height)
        bannerView.setupDataSource(type: .SERVER, imgUrlArray: imgUrl, hasTitle: true, titleArray: titleArray)
        
        view.addSubview(bannerView)
    }


}

