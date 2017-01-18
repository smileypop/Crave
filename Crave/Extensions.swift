//
//  Extensions.swift
//  Crave
//
//  Created by Matthew Laird on 1/12/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import Foundation
import UIKit

// Mark: - Custom extensions

extension Double {

    init(_ string: String) {
        guard let n = NumberFormatter().number(from: string) else {
            self = 0
            return
        }
        self = Double(n)
    }

    func toString() -> String {
        return String(format: "%.3f", self)
    }
}

extension String {

    mutating func trimPrefix(_ prefix: String) {

        if self.hasPrefix(prefix) {

            self.remove(at: self.startIndex)
        }
    }

    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }

    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }

    func replace(target: String, strings: String...) -> String {
        var newString = self

        for string in strings {
            newString = newString.stringByReplacingFirstOccurrenceOfString(target: target, withString: string)
        }

        return newString
    }
}

extension UIView {

    func fadeInOutRepeat(duration: Double, delay: Double = 0) {

        self.layer.removeAllAnimations()

        self.alpha = 0.0

        UIView.animateKeyframes(withDuration: duration, delay: delay, options: [.repeat], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                self.alpha = 1.0
            })
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 2/3, animations: {
                self.alpha = 0.0
            })
        })
    }

    func scaleRepeat(duration: Double, delay: Double, startScale: CGFloat, endScale: CGFloat) {

        self.layer.removeAllAnimations()

        self.transform = CGAffineTransform(scaleX: startScale, y: startScale)

        UIView.animateKeyframes(withDuration: duration, delay: delay, options: [.repeat], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
            })
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 2/3, animations: {
                self.transform = CGAffineTransform(scaleX: startScale, y: startScale)
            })
        })
    }

    func scale(duration: Double, startScale: CGFloat, endScale: CGFloat, onComplete: (() -> Void)? = nil) {

        self.layer.removeAllAnimations()

        self.transform = CGAffineTransform(scaleX: startScale, y: startScale)

        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        }, completion: {

            isComplete in

            onComplete?()
        })
    }
}

/*
 Code by GitHub user eMdOS
 https://gist.github.com/yannickl/16f0ed38f0698d9a8ae7
*/

extension String {
    var hex: Int? {
        return Int(self, radix: 16)
    }
}

extension UIColor {
    convenience init(hex: Int) {
        self.init(hex: hex, a: 1.0)
    }

    convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }

    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }

    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }

    convenience init?(hexString: String) {
        guard let hex = hexString.hex else {
            return nil
        }
        self.init(hex: hex)
    }

/* end */
    
}
