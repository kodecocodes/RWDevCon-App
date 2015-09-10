//
//  VideoPlayerViewController.swift
//  RWDevCon
//
//  Created by Pietro Rea on 9/8/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayerViewController: AVPlayerViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }

  @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
