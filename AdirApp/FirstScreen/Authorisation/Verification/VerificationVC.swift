//
//  VerificationVC.swift
//  AdirApp
//
//  Created by iMac1 on 04.11.2021.
//

import UIKit

final class VerificationVC: BaseVC {
    
    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var mainImageView: UIImageView!
    @IBOutlet private var verifyTitleLabel: UILabel! {
        didSet{
            verifyTitleLabel.text = "Verify your email"
        }
    }
    @IBOutlet private var verifyDescriptionLabel: UILabel! {
        didSet{
            verifyDescriptionLabel.text = "We send a verification email to  . Please tap the link inside that email to continue"
        }
    }
    @IBOutlet private var checkInboxLabel: UILabel! {
        didSet{
            checkInboxLabel.text = "Check my inbox"
        }
    }
    @IBOutlet private var resendLabel: UILabel! {
        didSet{
            resendLabel.text = "Resend email"
        }
    }
    @IBOutlet private var mainImageTopConstraint: NSLayoutConstraint!
    @IBOutlet private var checkMyInboxTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func keyboardWillShow(notification notif: NSNotification) {
        mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: getKeyboardHeight(notif) , right: 0)
    }
    
    override func keyboardWillHide(notification _: NSNotification) {
        mainScrollView.contentInset = .zero
    }
    
    var registrationModel: RegistrationModel?
    
    private func setupView() {
        setupLargeConstraints()
        setupTapGesture()
    }
    
    private func setupLargeConstraints() {
        if self.view.frame.height >= 700 {
            mainImageTopConstraint.constant = 80
            checkMyInboxTopConstraint.constant = 100
        } else {
            mainImageTopConstraint.constant = 25
            checkMyInboxTopConstraint.constant = 30
        }
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainScrollView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    @IBAction private func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func checkButtonAction(_ sender: UIButton) {
        guard let vc = homeStoryboard.instantiateViewController(identifier: "AddSchoolVC") as? AddSchoolVC else { return }
        guard let registrationModel = registrationModel else { return }
        vc.registrationModel = registrationModel
        self.navigationController?.pushViewController(vc, animated: true)
        //TODO verification Code action
    }
    
    @IBAction private func resendButtonAction(_ sender: UIButton) {
        //TODO resend mail action
    }
}
