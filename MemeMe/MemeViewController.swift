//
//  MemeViewController.swift
//  Meme
//
//  Created by user on 02/01/2021.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
       .foregroundColor: UIColor.black,
       .strokeColor: UIColor.white,
       .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth: 4.0
    ]
    
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // disable camera button if camera is not supported on device
        cameraBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // disable share button because image is nil
        shareBarButton.isEnabled = false
        
        // set all attributes of text in both top and bottom textfield
        bottomTextField.delegate = bottomTextFieldDelegate
        bottomTextField.text = MemeViewController.bottomPlaceholderText
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        bottomTextField.textAlignment = .center
        
        topTextField.delegate = topTextFieldDelegate
        topTextField.text = MemeViewController.topPlaceholderText
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        
        // subscribe to keyboard notification
        subscribeToKeyboardNotifications()
        
    }
    
    deinit {
        // unsubscribe from keybaord notification
       unSubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unSubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
    
    // returns the height of the keyboard
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Tells the delegate what the user picked.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage{
            imageView.image = image
            // enabled the share button
            shareBarButton.isEnabled = true;
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // generate the MemeMe image to be shared
    func generateMemedImage() -> UIImage {
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false

        return memedImage
    }
    
    // save meme after sharing memed image
    func save(_ memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        print(meme.bottomText)
    }
    
    
    // MARK: IBActions

    @IBAction func pickImageFromAlbum(_ sender: Any) {
        let controller = UIImagePickerController()
        
        controller.delegate = self
        controller.sourceType = .photoLibrary
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func pickImageUsingCamera(_ sender: Any) {
        let controller = UIImagePickerController()
        
        controller.delegate = self
        controller.sourceType = .camera
        
        present(controller, animated: true, completion: nil)
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
    
    // return app to launch state
    @IBAction func cancel(_ sender: Any) {
        imageView.image = nil
        topTextField.text = MemeViewController.topPlaceholderText
        bottomTextField.text = MemeViewController.bottomPlaceholderText
        shareBarButton.isEnabled = false
    }
}








