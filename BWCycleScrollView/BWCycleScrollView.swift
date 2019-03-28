//
//  BWCycleScrollView.swift
//  BWCycleScrollView
//
//  Created by test on 2019/3/15.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SnapKit

public class BWCycleScrollView: UIView, UIScrollViewDelegate {

    let KScreenWidth:CGFloat = 100
    let scrollHeight:CGFloat = 220
    var scrollView:UIScrollView!
    var pageControl:UIPageControl!
    //定时器
    var autoScrollTimer:Timer?
    //用于轮播的左中右三个image（不管几张图片都是这三个imageView交替使用）
    var leftImageView , middleImageView , rightImageView : UIImageView!
    var leftTitleLabel, middleTitleLabel, rightTitleLabel: UILabel!
    //dataSource
    var imgDataArray:[ImageData] = [ImageData]()
    var titleArray:[StringData] = [StringData]()
    //index of current page
    var currentPage:Int = 0
    let default_image = UIImage(named: "Image_Preview")
    
    func initScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: scrollHeight))
        scrollView.contentSize = CGSize(width: KScreenWidth*3, height: 0)
        scrollView.contentOffset = CGPoint(x: KScreenWidth, y: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        
        pageControl = UIPageControl()
        pageControl.backgroundColor = UIColor.clear
        pageControl.numberOfPages = imgDataArray.count
        pageControl.currentPage = self.currentPage
        
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        
        pageControl.snp.makeConstraints{(make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self).offset(-5)
            make.height.width.equalTo(20)
        }
        
        configureImageViews()
        configureAutoScrollTimer()
    }
    
    func configureImageViews() {
        leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: scrollHeight))
        middleImageView = UIImageView(frame: CGRect(x: KScreenWidth, y: 0, width: KScreenWidth, height: scrollHeight))
        rightImageView = UIImageView(frame: CGRect(x: 2*KScreenWidth, y: 0, width: KScreenWidth, height: scrollHeight))
        
        // configure titleLabel
        leftTitleLabel = UILabel()
        leftTitleLabel.numberOfLines = 0
        leftTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        leftTitleLabel.textColor = UIColor.white
        middleTitleLabel = UILabel()
        middleTitleLabel.numberOfLines = 0
        middleTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        middleTitleLabel.textColor = UIColor.white
        rightTitleLabel = UILabel()
        rightTitleLabel.numberOfLines = 0
        rightTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        rightTitleLabel.textColor = UIColor.white
        
        leftImageView.addSubview(leftTitleLabel)
        middleImageView.addSubview(middleTitleLabel)
        rightImageView.addSubview(rightTitleLabel)
        
        // titleLabel layout
        leftTitleLabel.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(leftImageView.snp.bottom).offset(-25)
            make.left.equalTo(leftImageView).offset(20)
            make.right.equalTo(leftImageView).offset(-20)
        }
        middleTitleLabel.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(middleImageView.snp.bottom).offset(-25)
            make.left.equalTo(middleImageView).offset(20)
            make.right.equalTo(middleImageView).offset(-20)
        }
        rightTitleLabel.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(rightImageView.snp.bottom).offset(-25)
            make.left.equalTo(rightImageView).offset(20)
            make.right.equalTo(rightImageView).offset(-20)
        }
        
        //图片切割显示
        leftImageView.contentMode = .scaleAspectFill
        middleImageView.contentMode = .scaleAspectFill
        rightImageView.contentMode = .scaleAspectFill
        leftImageView.clipsToBounds = true
        middleImageView.clipsToBounds = true
        rightImageView.clipsToBounds = true
        
        if !self.imgDataArray.isEmpty {
            self.setImageView()
        }
        
        scrollView.addSubview(leftImageView)
        scrollView.addSubview(middleImageView)
        scrollView.addSubview(rightImageView)
    }
    
    func setImageView() {
        //scrollView is displaying the first data in imgDataArray
        if currentPage == 0 {
            leftImageView.sd_setImage(with: URL(string: imgDataArray.last!.imageUrl!), placeholderImage: default_image)
            leftTitleLabel.text = imgDataArray.last!.title
            middleImageView.sd_setImage(with: URL(string: imgDataArray.first!.imageUrl!), placeholderImage: default_image)
            middleTitleLabel.text = imgDataArray.first!.title
            rightImageView.sd_setImage(with: URL(string: imgDataArray[1].imageUrl!), placeholderImage: default_image)
            rightTitleLabel.text = imgDataArray[1].title
        }else if currentPage == imgDataArray.count - 1 {
            //last data in topStrories
            leftImageView.sd_setImage(with: URL(string: imgDataArray[currentPage - 1].imageUrl!), placeholderImage: default_image)
            leftTitleLabel.text = imgDataArray[currentPage - 1].title
            middleImageView.sd_setImage(with: URL(string: imgDataArray.last!.imageUrl!), placeholderImage: default_image)
            middleTitleLabel.text = imgDataArray.last!.title
            rightImageView.sd_setImage(with: URL(string: imgDataArray.first!.imageUrl!), placeholderImage: default_image)
            rightTitleLabel.text = imgDataArray.first!.title
        }else {
            //其他情况
            leftImageView.sd_setImage(with: URL(string: imgDataArray[currentPage - 1].imageUrl!), placeholderImage: default_image)
            leftTitleLabel.text = imgDataArray[currentPage - 1].title
            middleImageView.sd_setImage(with: URL(string: imgDataArray[currentPage].imageUrl!), placeholderImage: default_image)
            middleTitleLabel.text = imgDataArray[currentPage].title
            rightImageView.sd_setImage(with: URL(string: imgDataArray[currentPage + 1].imageUrl!), placeholderImage: default_image)
            rightTitleLabel.text = imgDataArray[currentPage + 1].title
        }
    }
    
    //设置自动滚动计时器
    func configureAutoScrollTimer() {
        //设置一个定时器，每6秒钟滚动一次
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 6, target: self,
                                               selector: #selector(letItScroll),
                                               userInfo: nil, repeats: true)
    }
    
    //计时器时间一到，滚动一张图片
    @objc func letItScroll(){
        let offset = CGPoint(x: 2*KScreenWidth, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    //MARK: DELEGATE
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        
        if !imgDataArray.isEmpty {
            
            //如果向左滑动（显示下一张）
            if(offset >= KScreenWidth*2){
                //还原偏移量
                scrollView.contentOffset = CGPoint(x: KScreenWidth, y: 0)
                //视图索引+1
                currentPage += 1
                
                if currentPage == imgDataArray.count {
                    currentPage = 0
                }
            }
            
            //如果向右滑动（显示上一张）
            if(offset <= 0){
                //还原偏移量
                scrollView.contentOffset = CGPoint(x: KScreenWidth, y: 0)
                //视图索引-1
                currentPage -= 1
                
                if currentPage == -1 {
                    currentPage = imgDataArray.count - 1
                }
            }
            
            //重新设置各个imageView的图片
            setImageView()
            //设置页控制器当前页码
            self.pageControl.currentPage = self.currentPage
        }
    }
    
    //手动拖拽滚动开始
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //使自动滚动计时器失效（防止用户手动移动图片的时候这边也在自动滚动）
        autoScrollTimer?.invalidate()
    }
    
    //手动拖拽滚动结束
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        //重新启动自动滚动计时器
        configureAutoScrollTimer()
        
    }

}
