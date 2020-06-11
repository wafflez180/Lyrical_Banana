//
//  ErrorManager.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/11/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

class ErrorManager: NSObject {
    static let shared = ErrorManager()
    
    // MARK: - ErrorManager
    
    func presentErrorAlert(title: String, error: Error){
        presentErrorAlert(title: title, errorDescription: error.localizedDescription)
    }

    func presentErrorAlert(title: String, errorDescription: String){
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller

            let alert = UIAlertController(title: title, message: errorDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
