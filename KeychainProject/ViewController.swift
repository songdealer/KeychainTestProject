//
//  ViewController.swift
//  KeychainProject
//
//  Created by user on 2/23/26.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    
    private let keychainUtils: KeychainUtils = KeychainUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func findButtonClicked(_ sender: Any) {
        guard let key = keyTextField.text, let data = try? keychainUtils.read(key: key) else { return }
        
        let ret = String(data: data, encoding: .utf8)
        
        valueLabel.text = "value: \(ret)"
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let key = keyTextField.text, let value = valueTextField.text?.data(using: .utf8, allowLossyConversion: false) else { return }
        
        try? keychainUtils.save(key: key, data: value)
    }
}
