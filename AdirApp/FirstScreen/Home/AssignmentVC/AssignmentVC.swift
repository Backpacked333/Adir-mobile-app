//
//  AssignmentVC.swift
//  AdirApp
//
//  Created by iMac1 on 03.12.2021.
//

import UIKit
import WebKit

final class AssignmentVC: UIViewController {
    
    @IBOutlet private var titleContainerView: UIView!
    @IBOutlet private var mainTitleLabel: UILabel!
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    var urlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        setupWebView()
    }
    
    private func setupWebView() {
        guard let url = URL(string: urlString) else { return }
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @IBAction private func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AssignmentVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
}
