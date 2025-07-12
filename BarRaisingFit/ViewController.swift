//
//  ViewController.swift
//  BarRaisingFit
//
//  Created by Otis Young on 12/7/24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .link
    }

    @IBAction func didTapButton() {
        let homerView = Homer()
        let hostingController = UIHostingController(rootView: homerView)
        
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true, completion: nil)
    }
}
