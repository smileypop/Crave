//
//  Flickr.swift
//  Crave
//
//  Created by Matthew Laird on 1/14/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import Foundation
import SwiftyJSON

class Flickr {

    static let shared = Flickr()

    fileprivate init() {}

    // Search for a specific term
    class func searchFor(_ searchTerm: String, onSuccess : @escaping (FlickrSearchResult?) -> Void){

        // Check term to make sure it can be parsed
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {

            Alerter.showErrorAlert(message: messageNotAValidSearchTerm.replace(target: "%", strings: searchTerm))

            return
        }

        // Find the user location
        Locator.locate(onDisabled: {

            // User had disabled location - ask them for it
            isDisabled in

                Alerter.showEnableLocationAlert()

            }) { location in

                // Did we find the location?
            if let locationPoint = location {

                // Remove + symbol
                var lat = locationPoint.coordinate.latitude.toString()
                lat.trimPrefix("+")
                var lon = locationPoint.coordinate.longitude.toString()
                lon.trimPrefix("+")

                let url = flickrUrl + "&text=\(escapedTerm)&lat=\(lat)&lon=\(lon)" + flickrParams

                Networker.request(url: url,

                onSuccess: {

                    json in

                    // Check json for necessary properties
                    guard let dictionary = json["photos"].dictionary, let photos = dictionary["photo"]?.array, photos.count > 0 else {

                        Alerter.showSearchAgainAlert()

                        return
                    }

                    let flickrSearchResult = FlickrSearchResult(searchTerm: searchTerm, photos: Flickr.download(photos: photos))

                    onSuccess(flickrSearchResult)
                    
                    return

                }, onFail: {

                    // Fail - search again
                    Alerter.showSearchAgainAlert()

                    return

                }, onError: {

                    error in

                    // Error - show a message to user
                    Alerter.showErrorAlert(message: error.localizedDescription)

                    return
                })
            }  else {

                //
                Alerter.showErrorAlert(message: messageLocationCouldNotBeDetermined)

                return
            }
        }
    }

    // Download photos
    class func download(photos: [JSON]) -> [FlickrPhoto] {

        var flickrPhotos = [FlickrPhoto]()

        // Loop through each photo
        for photo in photos {

            guard let photoID = photo["id"].string,
                let farm = photo["farm"].int,
                let server = photo["server"].string,
                let secret = photo["secret"].string,
                let latitude = photo["latitude"].string,
                let longitude = photo["longitude"].string
                else {
                    break
            }

            let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret, latitude: latitude, longitude: longitude)

            flickrPhoto.dateTaken = photo["dateTaken"].string

            guard let url = flickrPhoto.flickrImageURL(),
                let imageData = try? Data(contentsOf: url as URL) else {
                    break
            }
            
            if let image = UIImage(data: imageData) {
                flickrPhoto.thumbnail = image
                flickrPhotos.append(flickrPhoto)
            }
            
        }
        
        return flickrPhotos
    }
}
