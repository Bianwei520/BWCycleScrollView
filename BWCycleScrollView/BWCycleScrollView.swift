//
//  BWCycleScrollView.swift
//  BWCycleScrollView
//
//  Created by test on 2019/3/15.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

public class BWCycleScrollView: UIView, UIScrollViewDelegate {
    private let width:CGFloat
    private let height:CGFloat
    
    private var scrollView:UIScrollView!
    private var pageControl:UIPageControl!
    //定时器
    private var autoScrollTimer:Timer?
    //用于轮播的左中右三个image（不管几张图片都是这三个imageView交替使用）
    private var leftImageView , middleImageView , rightImageView : UIImageView!
    private var leftTitleLabel, middleTitleLabel, rightTitleLabel: UILabel!
    //dataSource
    var imgDataArray:ImageData!
    var titleArray:[String]?
    //index of current page
    private var currentPage:Int = 0
    let default_image = UIImage(named: "Image_Preview")
    
    public init(frame:CGRect, scrollViewWidth width:CGFloat,
                scrollViewHeight height:CGFloat) {
        self.width = width
        self.height = height
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 设置数据源
    public func setupDataSource(type:DataType,
                         imgUrlArray imgUrl:[String],
                         hasTitle:Bool,
                         titleArray title:[String]?) {
        imgDataArray = ImageData(type: type, array: imgUrl)
        if hasTitle {
            titleArray = title
        }
        
        setupScrollView()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        scrollView.contentSize = CGSize(width: width*3, height: 0)
        scrollView.contentOffset = CGPoint(x: width, y: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        
        pageControl = UIPageControl()
        pageControl.backgroundColor = UIColor.clear
        pageControl.numberOfPages = imgDataArray.imageArray.count
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
    
    private func configureImageViews() {
        leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        middleImageView = UIImageView(frame: CGRect(x: width, y: 0, width: width, height: height))
        rightImageView = UIImageView(frame: CGRect(x: 2*width, y: 0, width: width, height: height))
        
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
        
        if !self.imgDataArray.imageArray.isEmpty {
            self.setImageView()
        }
        
        scrollView.addSubview(leftImageView)
        scrollView.addSubview(middleImageView)
        scrollView.addSubview(rightImageView)
    }
    
    private func setTitleLabel() {
        if titleArray != nil && !titleArray!.isEmpty {
            switch currentPage {
            case 0:
                leftTitleLabel.text = titleArray!.last
                middleTitleLabel.text = titleArray![0]
                rightTitleLabel.text = titleArray![1]
            case imgDataArray.imageArray.count - 1:
                leftTitleLabel.text = titleArray![currentPage-1]
                middleTitleLabel.text = titleArray!.last
                rightTitleLabel.text = titleArray!.first
            default:
                leftTitleLabel.text = titleArray![currentPage-1]
                middleTitleLabel.text = titleArray![currentPage]
                rightTitleLabel.text = titleArray![currentPage+1]
            }
        }
    }
    
    private func setImageView() {
        //scrollView is displaying the first data in imgDataArray
        if currentPage == 0 {
            switch imgDataArray.imageArray.last! {
            case .LOCAL(let name):
                leftImageView.image = UIImage(named: name)
            case .SERVER(let url):
                leftImageView.kf.setImage(with: url, placeholder: default_image)
            }
            
            switch imgDataArray[0] {
            case let .LOCAL(name):
                middleImageView.image = UIImage(named: name)
            case let .SERVER(url):
                middleImageView.kf.setImage(with: url, placeholder: default_image)
            }
            
            switch imgDataArray[1] {
            case let .LOCAL(name):
                rightImageView.image = UIImage(named: name)
            case let .SERVER(url):
                rightImageView.kf.setImage(with: url, placeholder: default_image)
            }
        }else if currentPage == imgDataArray.imageArray.count - 1 {
            //last data
            switch imgDataArray[currentPage - 1] {
            case .LOCAL(let name):
                leftImageView.image = UIImage(named: name)
            case .SERVER(let url):
                leftImageView.kf.setImage(with: url, placeholder: default_image)
            }
            
            switch imgDataArray[currentPage] {
            case .LOCAL(let name):
                middleImageView.image = UIImage(named: name)
            case .SERVER(let url):
                middleImageView.kf.setImage(with: url, placeholder: default_image)
            }
            
            switch imgDataArray[0] {
            case let .LOCAL(name):
                rightImageView.image = UIImage(named: name)
            case let .SERVER(url):
                rightImageView.kf.setImage(with: url, placeholder: default_image)
            }
        } else {
            //其他情况
            switch imgDataArray[currentPage - 1] {
            case .LOCAL(let name):
                leftImageView.image = UIImage(named: name)
            case .SERVER(let url):
                leftImageView.kf.setImage(with: url, placeholder: default_image)
            }
            
            switch imgDataArray[currentPage] {
            case .LOCAL(let name):
                middleImageView.image = UIImage(named: name)
            case .SERVER(let url):
                middleImageView.kf.setImage(with: url, placeholder: default_image)
            }
            
            switch imgDataArray[currentPage + 1] {
            case let .LOCAL(name):
                rightImageView.image = UIImage(named: name)
            case let .SERVER(url):
                rightImageView.kf.setImage(with: url, placeholder: default_image)
            }
        }
        setTitleLabel()
    }
    
    //设置自动滚动计时器
    private func configureAutoScrollTimer() {
        //设置一个定时器，每6秒钟滚动一次
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 6, target: self,
                                               selector: #selector(letItScroll),
                                               userInfo: nil, repeats: true)
    }
    
    //计时器时间一到，滚动一张图片
    @objc func letItScroll(){
        let offset = CGPoint(x: 2*width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    //MARK: DELEGATE
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        
        if !imgDataArray.imageArray.isEmpty {
            
            //如果向左滑动（显示下一张）
            if(offset >= width*2){
                //还原偏移量
                scrollView.contentOffset = CGPoint(x: width, y: 0)
                //视图索引+1
                currentPage += 1
                
                if currentPage == imgDataArray.imageArray.count {
                    currentPage = 0
                }
            }
            
            //如果向右滑动（显示上一张）
            if(offset <= 0){
                //还原偏移量
                scrollView.contentOffset = CGPoint(x: width, y: 0)
                //视图索引-1
                currentPage -= 1
                
                if currentPage == -1 {
                    currentPage = imgDataArray.imageArray.count - 1
                }
            }
            
            //重新设置各个imageView的图片
            setImageView()
            //设置页控制器当前页码
            self.pageControl.currentPage = self.currentPage
        }
    }
    
    //手动拖拽滚动开始
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //使自动滚动计时器失效（防止用户手动移动图片的时候这边也在自动滚动）
        autoScrollTimer?.invalidate()
    }
    
    //手动拖拽滚动结束
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        //重新启动自动滚动计时器
        configureAutoScrollTimer()
        
    }

}
