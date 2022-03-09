//
//  SignInVC.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 03.11.2021.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

final class SignInVC: BaseVC {
    
    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var mainTitle: UILabel! {
        didSet{
            mainTitle.text = "Sign In"
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
    @IBOutlet private var signInButton: UIButton! {
        didSet{
            signInButton.setTitle("Sign In", for: .normal)
        }
    }
    @IBOutlet private var createAccountButton: UIButton! {
        didSet{
            createAccountButton.setTitle("Create a new account", for: .normal)
        }
    }
    @IBOutlet private var signUpGoogleLabel: UILabel! {
        didSet{
            signUpGoogleLabel.text = "Sign in with Google"
        }
    }
    @IBOutlet private var signUpAppleLabel: UILabel! {
        didSet{
            signUpAppleLabel.text = "Sign in with Apple"
        }
    }
    @IBOutlet private var mainTitleBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var createNewAccTopConstraint: NSLayoutConstraint!
    
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
    
    private func setupView() {
        setupLargeConstraints()
        setupTapGesture()
    }
    
    private func setupLargeConstraints() {
        if self.view.frame.height >= 700 {
            mainTitleBottomConstraint.constant = 80
            createNewAccTopConstraint.constant = 200
        } else {
            mainTitleBottomConstraint.constant = 25
            createNewAccTopConstraint.constant = 30
        }
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
            self.showHomePage()
        }
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainScrollView.addGestureRecognizer(tap)
    }
    
    private func isValidInput() -> Bool {
        guard !emailCustomTextField.getText.isEmpty, !passwordCustomTextField.getText.isEmpty else {
            Utils.standardAlertMessage(message: "", title: "Fill all fields")
            return false
        }
        guard ValidationHelper.validateEmail(emailCustomTextField.getText) == .valid else {
            Utils.standardAlertMessage(message: "", title: "Invalid email")
            return false
        }
        guard ValidationHelper.validatePassword(passwordCustomTextField.getText) == .valid else {
            Utils.standardAlertMessage(message: "", title: "Invalid Passwords")
            return false
        }
        return true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    @IBAction private func signInButtonAction(_ sender: UIButton) {
        guard isValidInput() else { return }
        
        APIManager.login(email: emailCustomTextField.getText, password: passwordCustomTextField.getText) { [weak self] result in
            switch result {
            case let .success(token):
                let signInModel = SignInModel(aToken: token.access_token)
                AuthData.shared.setAuthData(withAuthenticationModel: AuthModel(signIn: signInModel))
                UserDefaultsService.saveToken(token: token.access_token)

                APIManager.getUser() { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case let .success(userModel):
                        UserDefaultsService.saveLoggedUserModel(model: userModel)
                        strongSelf.showHomePage()
                    case let .failure(error):
                        print(error)
                    }
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction private func createAccountButtonAction(_ sender: UIButton) {
        guard let vc = homeStoryboard.instantiateViewController(identifier: "SignUpVC") as? SignUpVC else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func singInGoogleButtonAction(_ sender: UIButton) {
        signInWithGoogle()
    }
    
    @IBAction private func signInAppleButtonAction(_ sender: UIButton) {
        setUpSignInApple()
    }
}

extension SignInVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            
            let defaults = UserDefaults.standard
            defaults.set(userIdentifier, forKey: "userIdentifier1")
            self.showHomePage()
        default:
            break
        }
    }
}

extension SignInVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
}
