//
//  ViewController.swift
//  Furie Series
//
//  Created by Rustam Khakhuk on 18.12.2021.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var funcView: FuncView!
    
    @IBOutlet weak var btn: NSButtonCell!
    
    @IBOutlet weak var field: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn.target = self
        btn.action = #selector(calculate)
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func calculate() {
        var value = field.intValue
        print(value)
        funcView.calculateFurie(of: Int(value))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

