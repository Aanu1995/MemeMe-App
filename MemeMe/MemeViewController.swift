//
//  MemeViewController.swift
//  Meme
//
//  Created by user on 02/01/2021.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, Helper{
    
    // MARK: IBOutlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    
    // MARK: TextField Delegates
    
    let topTextFieldDelegate = TopTextFieldDelegate()
    let bottomTextFieldDelegate = BottomTextFieldDelegate()
    
    // MARK: Static Properties
    static let topPlaceholderText:String = "TOP"
    static let bottomPlaceholderText: String = "BOTTOM"
    static var activeTextField: UITextField!
    
    // MARK: Properties
    
    var isKeyboardShown = false // implemented due to notification bug in IOS simulator
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        cameraBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // disable share button because image is nil
        shareBarButton.isEnabled = false
        
        topTextField.delegate = topTextFieldDelegate
        bottomTextField.delegate = bottomTextFieldDelegate
        
        configureTextField(topTextField, withText: MemeViewController.topPlaceholderText)
        
        configureTextField(bottomTextField, withText: MemeViewController.bottomPlaceholderText)
        
        subscribeToKeyboardNotifications(showKeyboardSelector: #selector(keyboardWillShow(_:)), hideKeyboardSelector: #selector(keyboardWillHide))
        
    }
    
    
    deinit {
       unSubscribeFromKeyboardNotifications()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage{
            imageView.image = image
            // enabled the share button
            shareBarButton.isEnabled = true;
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBActions

    @IBAction func pickImageFromAlbum(_ sender: Any) {
        presentImagePickerWith(sourceType: .photoLibrary)
    }
    
    @IBAction func pickImageUsingCamera(_ sender: Any) {
        presentImagePickerWith(sourceType: .camera)
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            if completed && error == nil {
                // save the meme object
                self.save(memedImage)
            }
        }
        
        self.present(controller, animated: true, completion: nil)
        
        // for ipad
        if let popOver = controller.popoverPresentationController {
          popOver.sourceView = self.view
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        imageView.image = nil
        topTextField.text = MemeViewController.topPlaceholderText
        bottomTextField.text = MemeViewController.bottomPlaceholderText
        shareBarButton.isEnabled = false
    }
}


// MARK: Extension on MemeViewController
extension MemeViewController{
    
    @objc func keyboardWillHide(){
        isKeyboardShown = false
        view.frame.origin.y = 0.0
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        if(notification.name == UIResponder.keyboardWillShowNotification && !isKeyboardShown){
            let keyBoardHeight = getKeyboardHeight(notification)
            
            if let activeField = MemeViewController.activeTextField {
                let realActiveTextFieldFrame = activeField.convert(activeField.frame, to: self.view)
                
                let textFieldHeightDiff = realActiveTextFieldFrame.origin.y - realActiveTextFieldFrame.height
                let keyboardHeightDiff = self.view.frame.height - keyBoardHeight
               
                let viewMoveDiff = keyboardHeightDiff - textFieldHeightDiff
                
                if viewMoveDiff < 0 {
                    isKeyboardShown = true
                    view.frame.origin.y -= keyBoardHeight
                }
            }
        }
    }
    
    func hideTopAndBottomBars(hide: Bool) {
        topToolBar.isHidden = hide
        bottomToolBar.isHidden = hide
    }
    
    func presentImagePickerWith(sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        
        controller.delegate = self
        controller.sourceType = sourceType
        
        present(controller, animated: true, completion: nil)
    }
    
    /**
     Create a memed image
     
     - Returns: A new UIImage from original image and top and bottom texts
    */
    func generateMemedImage() -> UIImage {
        hideTopAndBottomBars(hide:true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideTopAndBottomBars(hide:false)

        return memedImage
    }
    
    /**
     Save a meme
     
     - Parameter memedImage: image generated after combining original image and texts
    */
    func save(_ memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        print(meme.bottomText)
    }
}








