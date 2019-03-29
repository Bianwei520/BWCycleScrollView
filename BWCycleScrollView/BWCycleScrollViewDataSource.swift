//
//  BWCycleScrollViewDataSource.swift
//  BWCycleScrollView
//
//  Created by test on 2019/3/15.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

public enum DataType:Int {
    case SERVER = 0
    case LOCAL = 1
}

public enum DataSource {
    case SERVER(url:URL)
    case LOCAL(name:String)
}

public struct ImageData {
    var imageType:DataType = .SERVER
    var imageArray:[DataSource] = [DataSource]()
    
    subscript (index:Int) -> DataSource {
        get {
            return imageArray[index]
        }
    }
    
    init(type:DataType, array:[String]) {
        imageType = type
        if imageType == .SERVER {
            imageArray = array.map({ (urlStr) -> DataSource in
                return DataSource.SERVER(url: URL(string: urlStr)!)
            })
        } else {
            imageArray = array.map({ (name) -> DataSource in
                return DataSource.LOCAL(name: name)
            })
        }
    }
}

protocol BWCycleScrollViewDataSource {
    
}
