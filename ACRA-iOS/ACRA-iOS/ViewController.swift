//
//  ViewController.swift
//  ACRA-iOS
//
//  Created by Mr.RD on 2/6/17.
//  Copyright © 2017 Team Amazon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var testField: UITextView!
    @IBOutlet weak var searchInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide keyborad
        searchInput.resignFirstResponder()
        return true
    }
    //MARK: Actions
    @IBAction func searchButton(_ sender: UIButton) {
        //commenting out the update of text on screen when search pressed
        //testField.text = searchInput.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DestViewController: ProductViewController = segue.destination as! ProductViewController
        
        DestViewController.SearchLabel = searchInput.text!
        
    }


}

