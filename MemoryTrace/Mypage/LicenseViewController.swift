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
        self.title = "Open Source License"
        self.navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.white]
        self.textView.contentOffset = CGPoint(x: 0, y: 0)
    }
}
