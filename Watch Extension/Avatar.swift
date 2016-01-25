//
//  Avatar.swift
//  RWDevCon
//
//  Created by Mic Pringle on 18/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class Avatar {
  
  static let cache = Avatar()
  
  private var avatars = [String: UIImage]()
  
  func avatarForIdentifier(identifier: String?) -> UIImage? {
    guard let identifier = identifier else { return nil }
    if let avatar = avatars[identifier] { return avatar }
    if let image = UIImage(named: identifier) {
      let borderColor = UIColor(red: 13/255, green: 99/255, blue: 0, alpha: 1)
      let avatar = Toucan(image: image).maskWithEllipse(borderWidth: 4, borderColor: borderColor).image
      avatars[identifier] = avatar
      return avatar
    }
    return nil
  }
  
}