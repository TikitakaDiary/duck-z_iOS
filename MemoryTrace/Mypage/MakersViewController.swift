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
        setupMakersView()
    }
    
    private func setupMakersView() {
        self.view.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
        let scrollView = UIScrollView()
        let makersImageView = UIImageView(image: UIImage(named: "makers"))
        makersImageView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.width * 2.39) 
        makersImageView.contentMode = .scaleAspectFit
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
