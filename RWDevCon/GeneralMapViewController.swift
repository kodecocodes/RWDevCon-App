//
//  GeneralMapViewController.swift
//  RWDevCon
//
//  Created by Chris Wagner on 3/23/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class GeneralMapViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mapUrl = Bundle.main.url(forResource: "RWDevcon_Map_2017_v1.3", withExtension: "pdf")!
        let request = URLRequest(url: mapUrl)
        webView.loadRequest(request)
    }

}
