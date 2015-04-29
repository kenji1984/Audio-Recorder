//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Ken on 4/28/15.
//  Copyright (c) 2015 Ken. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL
    var title: String
    
    init(url: NSURL, name: String) {
        filePathUrl = url
        title = name
    }
}