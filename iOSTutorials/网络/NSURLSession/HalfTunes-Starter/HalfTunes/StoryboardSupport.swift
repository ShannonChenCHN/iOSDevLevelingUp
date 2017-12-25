//
//  StoryboardSupport.swift
//
//
//  Created by Richard Critz on 11/3/16.
//
//  Based on work by Andyy Hope (github.com/andyyhope)
//
//  Updated for Swift 4 by Audrey Tam on 11/6/17.
//

import UIKit

protocol StoryboardIdentifiable {
  static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
  static var storyboardIdentifier: String {
    return String(describing: self)
  }
}

extension StoryboardIdentifiable where Self: UICollectionViewCell {
  static var storyboardIdentifier: String {
    return String(describing: self)
  }
}

extension StoryboardIdentifiable where Self: UITableViewCell {
  static var storyboardIdentifier: String {
    return String(describing: self)
  }
}

extension UIViewController: StoryboardIdentifiable { }
extension UICollectionViewCell: StoryboardIdentifiable { }
extension UITableViewCell: StoryboardIdentifiable { }

extension UIStoryboard {
  
  //  If there are multiple storyboards in the project, each one must be named here:
  enum Storyboard: String {
    case Main
  }
  
  convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
    self.init(name: storyboard.rawValue, bundle: bundle)
  }
  
  class func storyboard(storyboard: Storyboard, bundle: Bundle?) -> UIStoryboard {
    return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
  }
  
  func instantiateViewController<T: UIViewController>() -> T {
    guard let viewController = instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
      fatalError("Could not find view controller with name \(T.storyboardIdentifier)")
    }
    
    return viewController
  }
  
}

extension UICollectionView {
  func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.storyboardIdentifier, for: indexPath) as? T else {
      fatalError("Could not find collection view cell with identifier \(T.storyboardIdentifier)")
    }
    return cell
  }
  
  func cellForItem<T: UICollectionViewCell>(at indexPath: IndexPath) -> T {
    guard let cell = cellForItem(at: indexPath) as? T else {
      fatalError("Could not get cell as type \(T.self)")
    }
    return cell
  }
}

extension UITableView {
  func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.storyboardIdentifier, for: indexPath) as? T else {
      fatalError("Could not find table view cell with identifier \(T.storyboardIdentifier)")
    }
    return cell
  }
  
  func cellForRow<T: UITableViewCell>(at indexPath: IndexPath) -> T {
    guard let cell = cellForRow(at: indexPath) as? T else {
      fatalError("Could not get cell as type \(T.self)")
    }
    return cell
  }
}

/// Use in view controllers:
///
/// 1) Have view controller conform to SegueHandlerType
/// 2) Add `enum SegueIdentifier: String { }` to conformance
/// 3) Manual segues are trigged by `performSegue(with:sender:)`
/// 4) `prepare(for:sender:)` does a `switch segueIdentifier(for: segue)` to select the appropriate segue case

protocol SegueHandlerType {
  associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
  
  func performSegue(with identifier: SegueIdentifier, sender: Any?) {
    performSegue(withIdentifier: identifier.rawValue, sender: sender)
  }
  
  func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
    guard   let identifier = segue.identifier,
      let segueIdentifier = SegueIdentifier(rawValue: identifier)
      else {
        fatalError("Invalid segue identifier: \(String(describing: segue.identifier))")
    }
    
    return segueIdentifier
  }
  
}
