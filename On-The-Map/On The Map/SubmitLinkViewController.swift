//
//  SubmitLink.swift
//  test
//
//  Created by Spiros Raptis on 05/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import WebKit
class SubmitLinkViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var searchBar: UISearchBar!
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        let text = searchBar.text
        let url = URL(string: text!)
        let req = URLRequest(url:url!)
        self.webView!.loadRequest(req)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.searchBar.delegate = self
        self.navigationController?.isToolbarHidden = false
        
        self.toolbarItems = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil),UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: #selector(SubmitLinkViewController.submit)),UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)]

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isToolbarHidden = true
    }
    //Submit URL. The URL will be entered in Share Link View
    func submit(){

        self.navigationController?.popViewController(animated: true)
        let applicationDelegate = (UIApplication.shared().delegate as! AppDelegate)
        if let sl = self.webView.request?.url!.absoluteString{
            applicationDelegate.shareLink = sl
        }else{
            applicationDelegate.shareLink = "Enter A Link To Share Here"
        }

    }
    
}
