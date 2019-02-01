//
//  MainViewController.swift
//  FlickrSearchDemo
//
//  Created by Abbas Angouti on 6/12/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import UIKit
import ReachabilitySwift

private let normalCellReuseIdentifier = "NormalCell"
private let loadCellReuseIdentifier = "LoadMoreCell"


class MainViewController: UICollectionViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var totalResult = 0
    var lastPage = 1
    var itemsPerRow = 4
    
    var alert: UIAlertController? = nil
    var noConnectionPresented = false
    
    var fetchedPhotos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
        setupReachability()
        
        collectionView?.backgroundColor = UIColor.white
        
        // Register cell classes
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: loadCellReuseIdentifier)
        
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        }
        
        
        fetchPhotos()
    }

    
    func fetchPhotos() {
        ApiClient.shared.getPhotos(for: "dogs", page: lastPage) { [unowned self] (result) in
            self.lastPage += 1
            switch result {
            case .error(let error):
                self.handleError(error: error)
                break
            case .success(let r):
                if let photos = r as? Photos {
                    self.handleNewPhotos(photosObject: photos)
                }
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateItemSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateItemSize()
    }
    
    
    func updateItemSize() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2.0
        let side = (Double(view.bounds.size.width) - Double(itemsPerRow - 1) * 2.0) / Double(itemsPerRow)
        layout.itemSize = CGSize(width: side, height: side)
    }
    
    
    private func setupSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}


extension MainViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}


extension MainViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedPhotos.count != totalResult, fetchedPhotos.count > 0 { // have not fetched all photos
            return fetchedPhotos.count + 1 // one for load more cell
        } else {
            return fetchedPhotos.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == fetchedPhotos.count { // load-more cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadCellReuseIdentifier, for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: normalCellReuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        cell.backgroundColor = UIColor(white: 235.0 / 255.0, alpha: 1.0)
        let imageView = imageViewForCell(cell)
        imageView.image = nil
        
        if let imageUrl = URL(string: fetchedPhotos[indexPath.row].url) {
            cell.downloadTask = ApiClient.shared.downloadImageTask(url: imageUrl, completion: { result in
                switch result {
                case .error(let error):
                    self.handleError(error: error)
                    break
                case .success(let r):
                    if let image = r as? UIImage {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                    break
                }
            })
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == fetchedPhotos.count {
            cell.backgroundColor = .clear
            buttonForCell(cell)
            return
        }
        
        if let _ = cell as? PhotoCollectionViewCell {
            (cell as! PhotoCollectionViewCell).downloadTask?.resume()
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _ = cell as? PhotoCollectionViewCell {
            (cell as! PhotoCollectionViewCell).downloadTask?.cancel()
        }
    }
    
    
    func handleNewPhotos(photosObject: Photos) {
        totalResult = Int(photosObject.total)!
        fetchedPhotos += photosObject.photoArray
    }
    
    
    func handleError(error: ApiClient.DataFetchError) {
        switch error {
        case .invalidURL:
            print("not a valid URL")
            break
        case .networkError(let message):
            print(message)
            break
        case .invalidResponse:
            print("invalid response from server")
            break
        case .serverError:
            print("unknown error received from server")
            break
        case .nilResult:
            print("unexpected nil in response")
            break
        case .invalidDataFormat:
            break
        case .jsonError(let message):
            print(message)
            break
        case .invalideDataType(let message):
            print(message)
            break
        case .unknownError:
            print("unknown error occured!")
        }
    }
    
    
    func imageViewForCell(_ cell: UICollectionViewCell) -> UIImageView {
        var imageView: UIImageView! = cell.viewWithTag(15) as? UIImageView
        if imageView == nil {
            imageView = UIImageView(frame: cell.bounds)
            imageView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
            imageView.tag = 15
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            cell.addSubview(imageView!)
        }
        return imageView!
    }
    
    
    func buttonForCell(_ cell: UICollectionViewCell) {
        var button: UIButton! = cell.viewWithTag(25) as? UIButton
        if button == nil {
            button = UIButton(frame: cell.bounds)
            button.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
            button.tag = 25
            button.clipsToBounds = true
            button.setTitle("Load More!", for: .normal)
            button.backgroundColor = .clear
            button.setTitleColor(.blue, for: .normal)
            button.addTarget(self, action: #selector(loadMore), for: .touchUpInside)
            
            cell.addSubview(button!)
        }
    }
    
    
    @objc func loadMore(sender: UIButton!) {
        fetchPhotos()
    }

    
    
}


extension MainViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let fsivc = segue.destination as? FullScreenImageViewController {
            if let idx = collectionView?.indexPathsForSelectedItems?[0] {
                let tappedPhoto = fetchedPhotos[idx.row]
                fsivc.imageTitle = tappedPhoto.title
            }
        }
    }
}


// to monitor internet reachability
extension MainViewController {
    
    func setupReachability() {
        ReachabilityManager.shared.reachabilityChangeBlock =  reachabilityChanged
    }
    
    
    func reachabilityChanged(reachability: Reachability) {
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            if !noConnectionPresented {
                self.noConnectionPresented = true
                alert = UIAlertController(title: "No Connection",
                                          message: "You are not connected to the Internet. Please check you Settings",
                                          preferredStyle: .alert)
                present(alert!, animated: true, completion: nil)
            }
            break
        default: // .reachableViaWiFi || .reachableViaWWAN
            if noConnectionPresented {
                self.noConnectionPresented = false
                alert?.dismiss(animated: true, completion: nil)
            }
            break
        }
    }
}

