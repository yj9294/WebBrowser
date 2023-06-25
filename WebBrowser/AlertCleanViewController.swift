//
//  AlertCleanViewController.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import UIKit

class AlertCleanViewController: UIViewController {
    
    var confirmHandle:(()->Void)? = nil
    
    init(confirm:(()->Void)? = nil) {
        super.init(nibName: "AlertCleanViewController", bundle: .main)
        self.confirmHandle = confirm
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func confirmAction() {
        back()
        confirmHandle?()
    }
    
    @IBAction func back() {
        self.dismiss(animated: true)
    }
}
