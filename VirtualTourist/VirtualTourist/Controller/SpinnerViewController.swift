//
//  SpinnerViewController.swift
//  VirtualTourist
//
//  Created by Darko Kulakov on 2019-05-23.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
// How to use spinner.

//let spinner = SpinnerViewController()
//func showSpinner(){
//    addChild(spinner)
//    spinner.view.frame = view.frame
//    view.addSubview(spinner.view)
//    spinner.didMove(toParent: self)
//}
//
//func hideSpinner(){
//    DispatchQueue.main.async {
//        self.spinner.willMove(toParent: nil)
//        self.spinner.view.removeFromSuperview()
//        self.spinner.removeFromParent()
//    }
//}
