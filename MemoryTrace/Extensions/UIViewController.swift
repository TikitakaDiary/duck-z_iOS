//
//  UIViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/16.
//

import UIKit
import Toast_Swift

extension UIViewController {
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    func showAlert(title: String, message: String, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message:
                                        message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showToast(message: String, position: ToastPosition) {
        var style = ToastStyle()
        style.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        style.messageColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
        style.messageFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        style.cornerRadius = 15
        
        self.view.makeToast(message, duration: 1, position: position, style: style)
    }
    
    func toolbarSetup(textView: UITextView? = nil, textField: UITextField? = nil) {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 38)
        toolbar.barTintColor = UIColor.white
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btnImg = UIImage.init(named: "Input_keyboard_icn")!.withRenderingMode(.alwaysOriginal)
        
        let hideKeybrd = UIBarButtonItem(image: btnImg, style: .done, target: self, action: #selector(hideKeyboard))
        toolbar.setItems([flexibleSpace, hideKeybrd], animated: false)
        
        if let textView = textView {
            textView.inputAccessoryView = toolbar
        }
        
        if let textField = textField {
            textField.inputAccessoryView = toolbar
        }
    }
    
    @objc func hideKeyboard(_ sender: Any){
        self.view.endEditing(true)
    }
}
