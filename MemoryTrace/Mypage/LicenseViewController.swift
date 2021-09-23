//
//  LicenseViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/29.
//

import UIKit

class LicenseViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.title = "Open Source License"
        self.navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.white]
        self.textView.contentOffset = CGPoint(x: 0, y: 0)
        let padding = self.view.frame.width * 0.06
        self.textView.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
}
