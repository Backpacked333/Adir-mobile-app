//
//  SignUp.swift
//  AdirApp
//
//  Created by iMac1 on 04.11.2021.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

final class SignUpVC: BaseVC {
    
    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var mainTitleLabel: UILabel! {
        didSet{
            mainTitleLabel.text = "Create account"
        }
    }
    @IBOutlet private var nameCustomTextField: CustomTextFieldView! {
        didSet{
            nameCustomTextField.setupField(icon: #imageLiteral(resourceName: "person").withTintColor(.lightText), placeholder: "FULL NAME")
        }
    }
    @IBOutlet private var emailCustomTextField: CustomTextFieldView! {
        didSet{
            emailCustomTextField.setupField(icon: #imageLiteral(resourceName: "mail").withTintColor(.lightText), placeholder: "EMAIL")
        }
    }
    @IBOutlet private var passwordCustomTextField: CustomTextFieldView! {
        didSet{
            passwordCustomTextField.setupField(icon: #imageLiteral(resourceName: "lock").withTintColor(.lightText), placeholder: "PASSWORD")
        }
    }
    @IBOutlet private var confirmPasswordCustomTextField: CustomTextFieldView! {
        didSet{
            confirmPasswordCustomTextField.setupField(icon: #imageLiteral(resourceName: "lock").withTintColor(.lightText), placeholder: "CONFIRM PASSWORD")
        }
    }
    @IBOutlet private var createButton: UIButton! {
        didSet{
            createButton.setTitle("Create", for: .normal)
        }
    }
    @IBOutlet private var logInButton: UIButton! {
        didSet{
            logInButton.setTitle("Log in to existing account", for: .normal)
        }
    }
    @IBOutlet private var signUpGoogleLabel: UILabel! {
        didSet{
            signUpGoogleLabel.text = "Sign up with Google"
        }
    }
    @IBOutlet private var signUpAppleLabel: UILabel! {
        didSet{
            signUpAppleLabel.text = "Sign up with Apple"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
    }
    
    override func keyboardWillShow(notification notif: NSNotification) {
        mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: getKeyboardHeight(notif) , right: 0)
    }
    
    override func keyboardWillHide(notification _: NSNotification) {
        mainScrollView.contentInset = .zero
    }
    
    private func setUpSignInApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    private func signInWithGoogle() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user, let profile = user.profile else { return }
            let googleUser = GoogleUserModel(email: profile.email, refreshToken: user.authentication.refreshToken)
            self.emailCustomTextField.fillTextField(text: googleUser.email)
            //TODO If sign in succeeded, display the app's main content View.
            guard let vc = homeStoryboard.instantiateViewController(identifier: "VerificationVC") as? VerificationVC else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainScrollView.addGestureRecognizer(tap)
    }
    
    private func isValidInput() -> Bool {
        guard !nameCustomTextField.getText.isEmpty,
              !emailCustomTextField.getText.isEmpty,
              !passwordCustomTextField.getText.isEmpty,
              !confirmPasswordCustomTextField.getText.isEmpty else {
            Utils.standardAlertMessage(message: "", title: "Fill all fields")
            return false
        }
        guard ValidationHelper.validateName(nameCustomTextField.getText) == .valid else {
            Utils.standardAlertMessage(message: "", title: "Invalid name")
            return false
        }
        guard ValidationHelper.validateEmail(emailCustomTextField.getText) == .valid else {
            Utils.standardAlertMessage(message: "", title: "Invalid email")
            return false
        }
        guard passwordCustomTextField.getText == confirmPasswordCustomTextField.getText else {
            Utils.standardAlertMessage(message: "", title: "Passwords not match")
            return false
        }
        guard ValidationHelper.validatePassword(confirmPasswordCustomTextField.getText) == .valid else {
            Utils.standardAlertMessage(message: "", title: "Invalid Passwords")
            return false
        }
        return true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    @IBAction private func createButtonAction(_ sender: UIButton) {
        guard isValidInput() else { return }
        guard let vc = homeStoryboard.instantiateViewController(identifier: "ConnectCanvasVC") as? ConnectCanvasVC else { return }
        guard let verificationVC = homeStoryboard.instantiateViewController(identifier: "VerificationVC") as? VerificationVC else { return }
        verificationVC.registrationModel = RegistrationModel(
            name: nameCustomTextField.getText,
            email: emailCustomTextField.getText,
            password: confirmPasswordCustomTextField.getText
        )
//        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.pushViewController(verificationVC, animated: true) // TODO W8 for back Verification
    }
    
    @IBAction private func logInButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func signUpGoogleButtonAction(_ sender: UIButton) {
        signInWithGoogle()
    }
    
    @IBAction private func signUpAppleButtonAction(_ sender: UIButton) {
        setUpSignInApple()
    }
}

extension SignUpVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
        
            let defaults = UserDefaults.standard
            defaults.set(userIdentifier, forKey: "userIdentifier1")
            guard let vc = homeStoryboard.instantiateViewController(identifier: "VerificationVC") as? VerificationVC else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension SignUpVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
}
