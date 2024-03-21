//
//  BaseViewController.swift
//  Universe App
//
//  Created by Yuriy on 20.03.2024.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var activityIndicator: UIAlertController?
    
    func showAlert(title: String?, message: String?, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        }
        
        let deleteAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            completionHandler(true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showActivity() {
        activityIndicator = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        guard let activityAlert = activityIndicator else { return }
        activityAlert.view.addSubview(loadingIndicator)
        present(activityAlert, animated: true, completion: nil)
    }
    
    func dismissActivity() {
        activityIndicator?.dismiss(animated: true)
    }
    
    func showAllertMessage(text: String) {
        let alertController = UIAlertController(title: "", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
