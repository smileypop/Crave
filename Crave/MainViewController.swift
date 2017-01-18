//
//  MainViewController.swift
//  Crave
//
//  Created by Matthew Laird on 1/11/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import UIKit

// Main class - show a collection of photos when user searches for something to eat

class MainViewController: UICollectionViewController {

    // MARK: - Class Properties
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate var searchResult:FlickrSearchResult?
    fileprivate var selectedPhoto:FlickrPhoto?
    fileprivate var tapNavigationBarRecognizer: UITapGestureRecognizer!
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

    var largePhotoIndexPath: IndexPath? {
        didSet {

            var indexPaths = [IndexPath]()
            if let largePhotoIndexPath = largePhotoIndexPath {
                indexPaths.append(largePhotoIndexPath)
            }
            if let oldValue = oldValue {
                indexPaths.append(oldValue)
            }

            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItems(at: indexPaths)
            }) { completed in

                if let largePhotoIndexPath = self.largePhotoIndexPath {
                    self.collectionView?.scrollToItem(
                        at: largePhotoIndexPath,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }

    public var searchTerm: String?

    var searchButton: UIBarButtonItem?
    @IBOutlet weak var activityView: UIView!

    // MARK: - Class Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(ImageViewCell.self, forCellWithReuseIdentifier: reuseIdentifierImageViewCell)

        // Do any additional setup after loading the view.

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.addObservers()

        self.tapNavigationBarRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapNavigationBar))

        self.searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(OnTapSearchButton))

        self.collectionView?.backgroundView = activityView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if searchTerm == nil {
            Alerter.showSearchAlert()
        }

        self.addRecognizers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.removeRecognizers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

        if segue.identifier == segueIdentifierShowMapView {

            if let mapViewController = segue.destination as? MapViewController {

                mapViewController.photo = self.selectedPhoto
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    // We only use 1 section
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // We show a view for each photo
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searchResult?.photos.count ?? 0
    }

    // Create or reuse a view for each photo
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: ImageViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierImageViewCell, for: indexPath) as! ImageViewCell

        cell.backgroundColor = UIColor.white

        cell.activityIndicator.stopAnimating()

        let photo = photoForIndexPath(indexPath)

        selectedPhoto = photo

        // Check for large photo
        guard indexPath == largePhotoIndexPath else {
            cell.imageView.image = photo.thumbnail

            // Hide map button for small photos
            cell.mapButton.isHidden = true
            cell.mapButton.isEnabled = false

            return cell
        }


        // Show map button for large photos
        cell.mapButton.isHidden = false
        cell.mapButton.isEnabled = true

        // Reuse large photo if it's already loaded
        guard photo.largeImage == nil else {
            cell.imageView.image = photo.largeImage
            return cell
        }

        cell.imageView.image = photo.thumbnail

        cell.activityIndicator.startAnimating()

        // Load a large photo
        photo.loadLargeImage { largePhoto, error in

            cell.activityIndicator.stopAnimating()

            guard largePhoto.largeImage != nil && error == nil else {
                return
            }

            if let cell = collectionView.cellForItem(at: indexPath) as? ImageViewCell,
                indexPath == self.largePhotoIndexPath  {
                cell.imageView.image = largePhoto.largeImage
            }
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate

    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */

    // Handle user selection - show / hide a large photo
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
        return false
    }

    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }

     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }

     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

     }
     */

}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Size for large photo - can be rectangle
        if indexPath == largePhotoIndexPath {
            let photo = photoForIndexPath(indexPath)
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.right)
            size.width -= (sectionInsets.left + sectionInsets.right)
            return photo.sizeToFillWidthOfSize(size)
        }

        // Size for small photo - always a square
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - Custom methods

extension MainViewController {

    // User taps search button in na bar
    @IBAction func OnTapSearchButton(_ sender: Any) {

        openSearch()
    }

    // User taps anywhere on the nav bar
    func onTapNavigationBar(_ gestureRecognizer: UITapGestureRecognizer) {

        openSearch()
    }

    // Let the user search for an item
    func openSearch() {

        toggleNavigationBar(hideBar: true)

        Alerter.showSearchAlert(searchTerm: self.searchTerm)
    }

    // Listen for notifications from search + errors
    func addObservers () {

        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onSearchNotification(notification:)), name: NSNotification.Name(rawValue: notificationIdentifierSearch), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onErrorNotification(notification:)), name: NSNotification.Name(rawValue: notificationIdentifierError), object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    func addRecognizers() {

        navigationController?.navigationBar.addGestureRecognizer(tapNavigationBarRecognizer)
    }

    func removeRecognizers() {
        navigationController?.navigationBar.removeGestureRecognizer(tapNavigationBarRecognizer)
    }

    // User started or cancelled a search
    @objc func onSearchNotification(notification: NSNotification) {

        if let searchTerm = notification.userInfo?[userInfoSearchTerm] as? String {

            self.searchTerm = searchTerm

            self.title = self.searchTerm
            self.searchResult = nil

            self.toggleActivityView(turnOn: true)

            // User chose a search term - now get it from Flickr
            Flickr.searchFor(searchTerm, onSuccess: {

                [weak self] searchResult in

                self?.toggleActivityView(turnOn: false)

                self?.searchResult = searchResult

                self?.toggleNavigationBar(hideBar: false, hideSearchIcon: false)

                if (searchResult == nil) {

                    // No results - search again

                    Alerter.showSearchAgainAlert()

                    return

                } else {

                    // Update the collection view with the new photos
                    self?.collectionView?.reloadData()

                    return
                }

            })

        } else {

            if self.searchTerm == nil {

                // No search term chosen - search again

                Alerter.showSearchAlert()

                return

            }

            self.toggleNavigationBar(hideBar: false, hideSearchIcon: false)
        }

    }

    // There was an error when searching
    @objc func onErrorNotification(notification: NSNotification) {

        if self.searchTerm == nil {

            // Ask the user to search for something new
            Alerter.showSearchAlert(searchTerm: self.searchTerm)

        } else {

            // Show the nav bar

            self.toggleActivityView(turnOn: false)

            self.toggleNavigationBar(hideBar: false, hideSearchIcon: false)

        }
    }

    // Get the photo for each view
    func photoForIndexPath(_ indexPath: IndexPath) -> FlickrPhoto {
        return (self.searchResult?.photos[(indexPath as IndexPath).row])!
    }

    // Hide or show the nav bar + search button
    func toggleNavigationBar(hideBar: Bool, hideSearchIcon: Bool = true) {

        var navigationBarItems = [UIBarButtonItem]()

        if !hideSearchIcon {
            navigationBarItems.append(searchButton!)
        }
        self.navigationItem.setRightBarButtonItems(navigationBarItems, animated: true)
        self.navigationController?.setNavigationBarHidden(hideBar, animated: true)
    }
    
    // Hide or show the activity view
    func toggleActivityView(turnOn: Bool) {
        
        if (turnOn) {
            
            self.collectionView?.backgroundColor = UIColor.white
            
            self.collectionView?.reloadData()
            
            self.activityView.isHidden = false
            
            self.activityView.fadeInOutRepeat(duration: 2)
            
        } else {
            
            self.activityView.layer.removeAllAnimations()
            
            self.activityView.isHidden = true
            
            self.collectionView?.backgroundColor = UIColor.black
            
        }
        
    }
}
