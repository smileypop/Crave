//
//  Networker.swift
//  Crave
//
//  Created by Matthew Laird on 1/14/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

// Class for making Network calls
class Networker {

    static let shared = Networker()

    fileprivate init() {}

    // Open App Settings
    class func openAppSettings(onComplete: @escaping (Bool) -> Void) {

        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: onComplete)
        }
    }

    // Try to make a server request
    class func request(url: String, onSuccess: ((JSON)->Void)? = nil, onFail: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil) {

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:

                if let resultValue = response.result.value {

                    let json = JSON(resultValue)

                    onSuccess?(json)

                } else {
                    onFail?()
                }

            case .failure(let error):
                print(error)

                onError?(error)
            }
        }
        
    }
}
