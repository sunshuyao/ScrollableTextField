//
//  ViewController.swift
//  ScrollableTextField
//
//  Created by Sun,Shuyao on 2019/10/21.
//  Copyright © 2019 Sun,Shuyao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let label1 = UILabel(frame: CGRect(x: 50, y: 100, width: 200, height: 50))
        label1.text = "ScrollableTextField"
        self.view.addSubview(label1)
        
        let scrollableTextField = ScrollableTextField(frame: CGRect(x: 50, y: 150, width: 200, height: 50))
        self.view.addSubview(scrollableTextField)
        scrollableTextField.backgroundColor = .green
        
        let label2 = UILabel(frame: CGRect(x: 50, y: 250, width: 200, height: 50))
        label2.text = "UITextField"
        self.view.addSubview(label2)
        let textFiled = UITextField(frame: CGRect(x: 50, y: 300, width: 200, height: 50))
        self.view.addSubview(textFiled)
        textFiled.backgroundColor = .red
    }


}

