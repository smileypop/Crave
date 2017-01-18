//
//  Alerter.swift
//  Crave
//
//  Created by Matthew Laird on 1/12/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import UIKit
import SCLAlertView
import AudioToolbox

// Class for showing various alerts to user
class Alerter {

    let shared = Alerter()

    fileprivate init() {}
    static var pendingNotification: (() -> Void)?

    // Save pending notifications if user leaves the app - post it when he/she gets back
    class func postPendingNotification() {

        pendingNotification?()
    }

    // Create a generic alert view
    class func createAlertView() -> SCLAlertView {

        let appearance = SCLAlertView.SCLAppearance(
            kCircleTopPosition: alertIconPosition,
            kCircleHeight: alertIconSize / 2,
            kCircleIconHeight: alertIconSize,
            showCloseButton: false
        )

        // Initialize SCLAlertView using custom Appearance
         return SCLAlertView(appearance: appearance)
    }

    // Ask the user to search for a new term
    class func showSearchAlert(searchTerm:String? = nil) {

        let alertView = Alerter.createAlertView()

        let textField = alertView.addTextField(defaultSearchTerm)
        textField.textAlignment = .center
        textField.autocapitalizationType = .none

        doAfter(delay: 0.5) {
            textField.becomeFirstResponder()
        }
        
        alertView.addButton(messageSearch, backgroundColor: darkRedColor, textColor: .white) {

            var userInfo = Dictionary<String, Any>()

            userInfo[userInfoSearchTerm] = textField.text?.isEmpty == false ? textField.text! : defaultSearchTerm

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIdentifierSearch), object: nil, userInfo: userInfo)

        }

        // Add a cancel button only if the user has already searched a term, so the UICollectionView isn't blank
        if searchTerm?.isEmpty == false {

            alertView.addButton(messageCancel, backgroundColor: lightGrayColor, textColor: .white) {

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIdentifierSearch), object: nil)

            }
        }

        alertView.showCustom("", subTitle: messageWhatAreYouCraving, color: .white, icon: UIImage(named: imageNameIcon)!)

    }

    // Ask the user to search again if there were no results for the search term they tried
    class func showSearchAgainAlert() {

        let alertView = Alerter.createAlertView()

        alertView.addButton(messageSearchAgain, backgroundColor: lightBlueColor, textColor: .white) {

            Alerter.showSearchAlert()
        }

        alertView.showCustom("", subTitle: messageNoResultsFound, color: .white, icon: UIImage(named: imageNameSearch)!)
    }

    // Show an error message
    class func showErrorAlert(message: String) {

        // Vibrate the device to give the user some feedback.
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        let alertView = Alerter.createAlertView()

        alertView.addButton(messageOK, backgroundColor: lightOrangeColor, textColor: .white) {

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIdentifierError), object: nil)
        }

        alertView.showCustom("", subTitle: message, color: .white, icon: UIImage(named: imageNameError)!)
    }

    // The user has disabled location services - ask them to turn it on
    class func showEnableLocationAlert(searchTerm:String? = nil) {

        let alertView = Alerter.createAlertView()

        alertView.addButton(messageGoToSettings, backgroundColor: lightBlueColor, textColor: .white) {

            Networker.openAppSettings {

                isComplete in

                // The user will live the app to go to settings - save a pending notifcation to post when they get back
                pendingNotification = {

                    doAfter(delay: 1) {

                        Alerter.showSearchAlert()
                    }
                }
            }
        }

        alertView.showCustom("", subTitle: messageTellLocation, color: .white, icon: UIImage(named: imageNameMap)!)

    }
}
