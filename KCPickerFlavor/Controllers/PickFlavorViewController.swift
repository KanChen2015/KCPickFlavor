//
//  ViewController.swift
//  IceCreamShop
//
//  Created by Joshua Greene on 2/8/15.
//  Copyright (c) 2015 Razeware, LLC. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

open class PickFlavorViewController: UIViewController, UICollectionViewDelegate {
  
  // MARK: Instance Variables
  
  var flavors: [Flavor] = [] {
    
    didSet {
      pickFlavorDataSource?.flavors = flavors
    }
  }
  
  fileprivate var pickFlavorDataSource: PickFlavorDataSource? {
    return collectionView?.dataSource as! PickFlavorDataSource?
  }
  
  fileprivate let flavorFactory = FlavorFactory()
  
  // MARK: Outlets
  
  @IBOutlet var contentView: UIView!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var iceCreamView: IceCreamView!
  @IBOutlet var label: UILabel!
  
  // MARK: View Lifecycle
  
  open override func viewDidLoad() {
    
    super.viewDidLoad()
    loadFlavors()
  }
  
  fileprivate func loadFlavors() {
    
    showLoadingHUD()  // <-- Add this line
    
    // 1

    let request = Alamofire.request("http://www.raywenderlich.com/downloads/Flavors.plist")
    request.responsePropertyList {[weak self] dataResponse in
      guard let strongSelf = self else { return }
      strongSelf.hideLoadingHUD()

      var flavorsArray: [[String : String]]! = nil

      // 3
      switch dataResponse.result {

      case .success(let array):
        if let array = array as? [[String : String]] {
          flavorsArray = array
        }
        case .failure(_):
        print("Couldn't download flavors!")
        return
      }

      // 4
      strongSelf.flavors = strongSelf.flavorFactory.flavorsFromDictionaryArray(flavorsArray)
      strongSelf.collectionView.reloadData()
      strongSelf.selectFirstFlavor()

    }
  }
  
  fileprivate func showLoadingHUD() {
    let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
    hud?.labelText = "Loading..."
  }
  
  fileprivate func hideLoadingHUD() {
    MBProgressHUD.hideAllHUDs(for: contentView, animated: true)
  }
  
  fileprivate func selectFirstFlavor() {
    
    if let flavor = flavors.first {
      updateWithFlavor(flavor)
    }
  }
  
  // MARK: UICollectionViewDelegate
  
  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let flavor = flavors[indexPath.row]
    updateWithFlavor(flavor)
  }
  
  // MARK: Internal
  
  fileprivate func updateWithFlavor(_ flavor: Flavor) {
    
    iceCreamView.updateWithFlavor(flavor)
    label.text = flavor.name
  }
}
