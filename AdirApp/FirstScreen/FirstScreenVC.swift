//
//  FirstScreenVC.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 03.11.2021.
//

import UIKit

class FirstScreenVC: BaseVC {
    
    override func viewDidLoad() {
        if AuthData.shared.isUserLoggedIn {
            openHomeScreen()
        } else {
            openAuthorisationScreen()
        }
    }
    
    private func openHomeScreen() {
        let vc = homeStoryboard.instantiateViewController(identifier: "HomeVC") as! HomeVC
        let nc = UINavigationController(rootViewController: vc)
        nc.isNavigationBarHidden = true
        nc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nc, animated: false)
    }
    
    private func openAuthorisationScreen() {
        let vc = homeStoryboard.instantiateViewController(identifier: "SignInVC") as! SignInVC
        let nc = UINavigationController(rootViewController: vc)
        nc.isNavigationBarHidden = true
        nc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nc, animated: false)
    }
}
