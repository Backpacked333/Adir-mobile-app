//
//  ConnectCanvas.swift
//  AdirApp
//
//  Created by iMac1 on 04.11.2021.
//

import UIKit

final class ConnectCanvasVC: BaseVC {
    
    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var lastStepLabel: UILabel! {
        didSet{
            lastStepLabel.text = "Last step!"
        }
    }
    @IBOutlet private var canvasImage: UIImageView!
    @IBOutlet private var connectAccountLabel: UILabel! {
        didSet{
            connectAccountLabel.text = "Connect to your Canvas\n account"
        }
    }
    @IBOutlet private var connectDescriptionLabel: UILabel! {
        didSet{
            connectDescriptionLabel.text = "Please connect to your Canvas account.\nWe need this to gather and organize your assignments for you"
        }
    }
    @IBOutlet private var canvasNameCustomTextField: CustomTextFieldView! {
        didSet{
            canvasNameCustomTextField.setupField(icon: #imageLiteral(resourceName: "person").withTintColor(.lightText), placeholder: "Canvas username")
        }
    }
    @IBOutlet private var canvasPasswordCustomTextField: CustomTextFieldView! {
        didSet{
            canvasPasswordCustomTextField.setupField(icon: #imageLiteral(resourceName: "lock").withTintColor(.lightText), placeholder: "Canvas password")
        }
    }
    @IBOutlet private var connectButtonTitleLabel: UILabel! {
        didSet{
            connectButtonTitleLabel.text = "Connect"
        }
    }
    @IBOutlet private var mainImageTopConstraint: NSLayoutConstraint!
    @IBOutlet private var descriptionBottomConstraint: NSLayoutConstraint!
    
    var registerModel: RegistrationModel?
    var schoolModel: SchoolModel?
    
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
            mainImageTopConstraint.constant = 40
            descriptionBottomConstraint.constant = 60
        } else {
            mainImageTopConstraint.constant = 25
            descriptionBottomConstraint.constant = 30
        }
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainScrollView.addGestureRecognizer(tap)
    }
    
    private func isValidInput() -> Bool {
        guard !canvasNameCustomTextField.getText.isEmpty else {
            Utils.standardAlertMessage(message: "Please fill name field", title: "Empty name")
            return false
        }
        guard !canvasPasswordCustomTextField.getText.isEmpty else {
            Utils.standardAlertMessage(message: "Please fill name field", title: "Empty password")
            return false
        }
        return true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    @IBAction private func connectButton(_ sender: UIButton) {
        guard isValidInput() else { return }
        
        schoolLogin(name: canvasNameCustomTextField.getText, password: canvasPasswordCustomTextField.getText)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Networking
extension ConnectCanvasVC {
    private func schoolLogin(name: String, password: String) {
        guard let schoolModel = schoolModel else { return }
        let params: [String: Any] = [
            "url": schoolModel.loginFormURL,
            "username": name,//,"Kosas1"
            "password": password //"EurichFortnite5"
        ]
        APIManager.schoolsLogin(params: params) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(success):
                strongSelf.patchSchool(
                    model: schoolModel,
                    name: name,
                    password: password)
                print(success)
            case let .failure(error):
                Utils.standardAlertMessage(message: "Problem with school login/password combination", title: "Error")
                print(error)
            }
        }
    }
    
    private func patchSchool(model: SchoolModel, name: String, password: String) {
        let params: [String: Any] = [
            "name": model.name,
            "login_form_url": model.loginFormURL,
            "logo_url": model.logoURL,
            "username": name,
            "password": password,
            "id": model.id,
            "created_at": model.createdAt
        ]
        
        APIManager.patchSchool(params: params) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(success):
                print(success)
                strongSelf.registration(name: name, password: password)
            case let .failure(error):
                if error.errMessage().contains("Status Code") {
                    strongSelf.registration(name: name, password: password)
                } else {
                    Utils.standardAlertMessage(message: "Problem with adding school to canvas account", title: "Error")
                    print(error)
                }
            }
        }
    }
    
    private func registration(name: String, password: String) {
        guard let model = registerModel else { return }
        
        APIManager.registration(
            userName: model.name,
            email: model.email,
            password: model.password,
            canvasLogin: name,
            canvasPassword: password) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case let .success(signupModel):
                    let token = signupModel.token.access_token
                    let signInModel = SignInModel(aToken: token)
                    UserDefaultsService.saveToken(token: token)
                    AuthData.shared.setAuthData(withAuthenticationModel: AuthModel(signIn: signInModel))
                    let userModel = UserModel(id: 0, email: model.email, full_name: model.name, last_login: "")
                    UserDefaultsService.saveLoggedUserModel(model: userModel)
                    strongSelf.showHomePage()
                case let .failure(error):
                    Utils.standardAlertMessage(message: "Canvas account doesn't exist", title: "Error")
                    print(error)
                }
            }
    }
}
