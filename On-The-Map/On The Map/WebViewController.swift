//
//  WebViewController.swift
//  On The Map
//  It displays a simple web view and loads a url which was most probably passed from
//  Another view.
//  Created by Spiros Raptis on 03/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    @IBOutlet var webView: UIWebView!
    
    var url:URL? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let u = url{
            let req = URLRequest(url:u)
            self.webView!.loadRequest(req)
        }
    }
}
