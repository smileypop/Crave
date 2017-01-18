//
//  Methods.swift
//  Crave
//
//  Created by Matthew Laird on 1/13/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import Foundation

// Do something after a delay
public func doAfter(delay seconds: Double, dispatchQueue: DispatchQueue = DispatchQueue.main, closure: @escaping () -> Void) {
    let dispatchTime = DispatchTime.now() + seconds
    dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
}
