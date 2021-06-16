//
//  MakersViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/16.
//

import UIKit

class MakersViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
        let scrollView = UIScrollView()
        let makersImageView = UIImageView(image: UIImage(named: "makers"))
        
        makersImageView.contentMode = .scaleAspectFill
        view.addSubview(scrollView)
        scrollView.addSubview(makersImageView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        scrollView.contentSize = makersImageView.bounds.size
        scrollView.showsVerticalScrollIndicator = false
    }
}
