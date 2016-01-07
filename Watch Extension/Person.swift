//
//  Person.swift
//  RWDevCon
//
//  Created by Mic Pringle on 07/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation

struct Person: Decodable {
  
  let id: String?
  let name: String?
  
  init?(json: JSON) {
    self.id = "id" <~~ json
    self.name = "name" <~~ json
  }
  
}