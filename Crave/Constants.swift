//
//  Constants.swift
//  Crave
//
//  Created by Matthew Laird on 1/11/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import Foundation
import UIKit

// Colors
let lightRedColor = UIColor(hexString: "FF6666")
let darkRedColor = UIColor(hexString: "da5b4b")
let lightGrayColor = UIColor(hexString: "d2d7d9")
let lightOrangeColor = UIColor(hexString: "e79e2d")
let lightBlueColor = UIColor(hexString: "4288bc")
let blueColor = UIColor(hexString: "53c0eb")

// Alerts
let alertIconPosition: CGFloat = -32
let alertIconSize: CGFloat = 128

// Messages
let messageSearch = "Search"
let messageSearchAgain = "Search Again"
let messageCancel = "Cancel"
let messageOK = "OK"
let messageGoToSettings = "Go to Settings"
let messageTellLocation = "Please tell us your location."
let messageNotAValidSearchTerm: String = "% is not a valid search term."
let messageLocationCouldNotBeDetermined: String = "Your location could not be determined."
let messageWhatAreYouCraving = "What are you craving?"
let messageNoResultsFound = "No results found."

// Image Names
let imageNameIcon = "Icon"
let imageNameError = "Error"
let imageNameSearch = "Search"
let imageNameMap = "Map"
let imageNameMapPin = "MapPin"

// User Info
let userInfoSearchTerm = "searchTerm"

// Segue Identifiers
let segueIdentifierShowMapView = "ShowMapView"

// Reuse Identifiers
let reuseIdentifierImageViewCell = "ImageViewCell"
let reuseIdentifierMapAnnotationPin = "MapAnnotationPin"

// Notification Identifiers
let notificationIdentifierError = "com.matthewlaird.Crave.notificationIdentifierError"
let notificationIdentifierSearch = "com.matthewlaird.Crave.notificationIdentifierSearch"

// Search
let defaultSearchTerm = "pizza"
let numberOfPhotosPerPage = 24

// Flickr
let flickrApiKey = "4f8fd87b9d7580cb8696df7fe5cc792b"
let flickrUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrApiKey)"
let flickrParams = "&per_page=\(numberOfPhotosPerPage)&format=json&nojsoncallback=1&media=photos&has_geo=1&radius=20&sort=date-taken-desc&extras=date_taken,geo"

// Result
enum Result <T> {
    case success(T)
    case failure(Error)
}
