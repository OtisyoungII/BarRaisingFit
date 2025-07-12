//
//  ViewController.swift
//  BarRaisingFit
//
//  Created by Otis Young on 12/7/24.
//

import UIKit

    class ViewController: UIViewController {
        override func viewDidLoad() {
            view.backgroundColor = .link
        }
        
        @IBAction func didTapButton() {
         guard   let vc = storyboard?.instantiateViewController(identifier: "second") as? SecondViewController else {
                print("failed to get vc from storyboard")
             return
            }
            
            present(vc, animated: true)
        }
        
}
