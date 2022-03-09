//
//  Utils.swift
//  Umity
//
//  Created by Vladyslav Kozlovskyi on 12.07.2021.
//

import UIKit

let appDELEGATE = UIApplication.shared.delegate as! AppDelegate

/// Struct describe one element in alert message
struct AlertAction {
    var title: String = ""
    var type: UIAlertAction.Style? = .default
    var enable: Bool? = true
    var selected: Bool? = false

    /**
     Initializes a new bicycle with the provided parts and specifications.

     - Parameters:
        - title: The title of action.
        - type: The type of action.
        - enable: The status is enable field.
        - selected: The staus show ✅ near field.

     - Returns: A new action item.

     - Remark: The action could use in `Utils.standartAlertMessage()` or `Utils.alertViewController`
     */
    init(title: String, type: UIAlertAction.Style? = .default, enable: Bool? = true, selected: Bool? = false) {
        self.title = title
        self.type = type
        self.enable = enable
        self.selected = selected
    }
}

/// class `Utils` that describes most powered functions
enum Utils {
    // MARK: - TOP VIEWCONTROLLER

    /// get top in hierarchie's ViewControllers
    static func topViewController(base: UIViewController? = appDELEGATE.window?.rootViewController) -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return base
    }

    // MARK: - ALERT ACTIONS

    /**
     Show fast standart alert with one button "OK"

     An example of using a *function*
     ````
     Utils.standartAlertMessage(message: "Error text", title: "Error titl", action: AlertAction(title: "Done", type: .destructive))
     ````
     */

    static func standardAlertMessage(message: String, title: String, action: AlertAction = .init(title: "OK")) {
        Utils.alertViewController(type: .alert, title: title, message: message, actions: [action], showCancel: false, actionHandler: nil)
    }

    /**
     Show custom Alert or Action sheet with complection handler
      - Parameters:
         - type: style: `.alert` or `.sheet`.
         - title: message title.
         - message: message.
         - actions: additional buttons.
         - showCancel: status is need to show last button with title "Cancel".
         - actionHandler: completion handler when pressed some button in actions.

      An example of using a *function*
      ~~~
      // Example:
      Utils.alertViewController(type: .actionSheet, with: "Title", message: "Message", actions: [AlertAction(title: "Btn first")], showCancel: true) { btn_Idx in
          switch btn_Idx {
          case 0: // 0 - Btn first
              break
          case 1: // 1 - Btn Cancel
              break
          default:
              break
          }
      }

      ~~~
     */
    static func alertViewController(type: UIAlertController.Style = .alert, title: String?, message: String?, actions: [AlertAction], showCancel: Bool, actionHandler: ((Int) -> Void)?) {
        guard let topVC = topViewController(), !topVC.isKind(of: UIAlertController.self) else {
            return
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: type)
        //        alertController.view.tintColor = Constants.Colors.dark

        // add actions
        for (index, action) in actions.enumerated() {
            let actionButton = UIAlertAction(title: action.title, style: action.type!, handler: { _ in
                actionHandler?(index)
            })

            actionButton.isEnabled = action.enable!
            if type == .actionSheet { actionButton.setValue(action.selected, forKey: "checked") }
            alertController.addAction(actionButton)
        }

        // add cancel button
        if showCancel {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                actionHandler?(actions.count)
            })
            alertController.addAction(cancelAction)
        }
        DispatchQueue.main.async {
            topVC.present(alertController, animated: true, completion: nil)
        }
    }
}
