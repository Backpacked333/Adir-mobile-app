//
//  GoToSafariVC.swift
//  AdirApp
//
//  Created by iMac1 on 10.02.2022.
//

import UIKit

final class GoToSafariVC: BaseVC {
    
    // MARK: - @IBOutlet
    
    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var mainTitleLabel: UILabel! {
        didSet {
            mainTitleLabel.text = "Step 1 of 2"
        }
    }
    @IBOutlet private var secondTitleLabel: UILabel! {
        didSet {
            secondTitleLabel.text = "Get your log in domain."
        }
    }
    @IBOutlet private var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = "Your log-domain is the where you go to log into your canvas account."
        }
    }
    @IBOutlet private var demoImageView: UIImageView! {
        didSet{
            guard let image = UIImage(named: "gifPlaceholder") else { return }
            demoImageView.image = image
        }
    }
    @IBOutlet private var demoGifLoadIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var instructionTextView: UITextView! {
        didSet {
            instructionTextView.text = "1. Go to safari\n\n2. Go to the page where you log into your canvas account\n\n3. Copy the web address\n\n4. Return to Adir and paste it"
        }
    }
    
    @IBOutlet private var goToSafariLabel: UILabel! {
        didSet {
            goToSafariLabel.text = "Go to safari"
        }
    }
    
    var addSchoolVC: BaseVC?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        demoGifLoadIndicator.stopAnimating()
        demoGifLoadIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainScrollView.setContentOffset(.zero, animated: false)
    }
    
    // MARK: - @IBAction
    
    @IBAction func goToSafariButtonAction(_ sender: UIButton) {
        guard let vc = homeStoryboard.instantiateViewController(identifier: "NameSchoolVC") as? NameSchoolVC else { return }
        guard let url = URL(string: "https://www.google.com") else { return }
        UIApplication.shared.open(url)
        vc.addSchoolVC = addSchoolVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
