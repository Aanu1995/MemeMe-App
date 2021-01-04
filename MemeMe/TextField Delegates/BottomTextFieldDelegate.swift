//
//  BottomTextFieldDelegate.swift
//  MemeMe
//
//  Created by user on 02/01/2021.
//

import UIKit

class BottomTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        MemeViewController.activeTextField = textField
        
        if(textField.text == MemeViewController.bottomPlaceholderText){
            textField.text = ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        // converts all text to uppercase
        let newTextString = String(newText).uppercased()
        textField.text = newTextString

        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.text == ""){
            textField.text = MemeViewController.bottomPlaceholderText
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        MemeViewController.activeTextField = nil
        return true
    }
}
