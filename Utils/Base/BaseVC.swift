//
//  BaseVC.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 28.10.2021.
//

import UIKit

let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)

class BaseVC: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backBtn: UIView!
    @IBOutlet var titleLabel: UILabel!

    // MARK: - Public Variables

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        listenNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    deinit {
        removeNotifications()
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let hasNOSafeArea = view.safeAreaInsets.bottom == 0.0
        return (keyboardHeight + (hasNOSafeArea ? 34.0 : 0.0) - 29)
    }
    
   
    // MARK: - IBActions

    @IBAction func onBtnBack(_: Any) {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)

        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Notification Methods

    func listenNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showHomePage() {
        let vc = homeStoryboard.instantiateViewController(identifier: "HomeVC") as! HomeVC
        let nc = UINavigationController(rootViewController: vc)
        nc.isNavigationBarHidden = true
        nc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nc, animated: true)
    }

    // MARK: - NSNotifications

    @objc func keyboardWillHide(notification _: NSNotification) {
        // override in child class
    }

    @objc func keyboardDidShow(notification _: NSNotification) {
        // override in child class
    }

    @objc func keyboardWillShow(notification _: NSNotification) {
        // override in child class
    }
    
    @objc func keyboardWillChangeFrame(notification _: NSNotification) {
        // override in child class
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BaseVC: UIGestureRecognizerDelegate {}

