//
//  NameSchoolVC.swift
//  AdirApp
//
//  Created by iMac1 on 10.02.2022.
//

import UIKit
import Alamofire

final class NameSchoolVC: BaseVC {
    
    @IBOutlet private var mainTitleLabel: UILabel! {
        didSet{
            mainTitleLabel.text = "Last step!"
        }
    }
    @IBOutlet private var secondTitleLabel: UILabel! {
        didSet{
            secondTitleLabel.text = "Submit your school."
        }
    }
    @IBOutlet private var descriptionLabel: UILabel! {
        didSet{
            descriptionLabel.text = "Now paste the the link you copied"
        }
    }
    @IBOutlet private var demoImageView: UIImageView! {
        didSet{
            guard let image = UIImage(named: "gifPlaceholder") else { return }
            demoImageView.image = image
        }
    }
    @IBOutlet private var imageLoadIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var logLinkTextField: UITextField! {
        didSet{
            logLinkTextField.borderStyle = .none
            logLinkTextField.attributedPlaceholder = NSAttributedString(
                string: "log-in link",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
            )
        }
    }
    @IBOutlet private var schoolNameTextField: UITextField! {
        didSet{
            schoolNameTextField.borderStyle = .none
            schoolNameTextField.attributedPlaceholder = NSAttributedString(
                string: "name of the school",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
            )
        }
    }
    @IBOutlet private var submitLabel: UILabel! {
        didSet{
            submitLabel.text = "Submit"
        }
    }
    @IBOutlet private var blockerView: UIView!
    @IBOutlet private var blockerActivityIndicator: UIActivityIndicatorView!
    
    var addSchoolVC: BaseVC?
    
    weak var delegate: AddSchoolDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageLoadIndicator.stopAnimating()
        imageLoadIndicator.isHidden = true
        hideBlocker()
    }
    
    private func showBlocker() {
        blockerView.isHidden = false
        blockerActivityIndicator.startAnimating()
    }
    
    private func hideBlocker() {
        blockerView.isHidden = true
        blockerActivityIndicator.stopAnimating()
    }
    
    // MARK: - @IBAction
    @IBAction func submitButtonAction(_ sender: UIButton) {
        addSchool()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Network
extension NameSchoolVC {
    private func addSchool() {
        guard let text = logLinkTextField.text, ValidationHelper.verifyUrl(urlString: text) else {
            Utils.standardAlertMessage(message: "The \"Link\" field must be a URL link ", title: "Error")
            return
        }
        guard let name = schoolNameTextField.text, !name.isEmpty else {
            Utils.standardAlertMessage(message: "Fill in the name field", title: "Error")
            return
        }
        let params: [String: Any] = [
            "name": name,
            "login_form_url": text,
            "logo_url": "https://cdn2.iconfinder.com/data/icons/maps-and-locations/12/school-512.png"
        ]
        showBlocker()
        APIManager.addSchool(params: params) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(school):
                guard let addSchoolVC = strongSelf.addSchoolVC as? AddSchoolVC else { return }
                strongSelf.delegate = addSchoolVC
                strongSelf.delegate?.school(model: school)
                strongSelf.navigationController?.popToViewController(addSchoolVC, animated: true)
            case let .failure(error):
                print(error.localizedDescription)
            }
            strongSelf.hideBlocker()
        }
    }
}
