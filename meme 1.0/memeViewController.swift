//
//  ViewController.swift
//  meme 1.0
//
//  Created by Maxime VALENCIK on 9/28/21.
//

import UIKit

class memeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //Declare Meme structure
    struct Meme{
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    //Default text properties
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth : -3
    ]
    
    //Life cycle
    
    func setupTextField(_ textField: UITextField, text: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.text=text
        textField.textAlignment = NSTextAlignment.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup text components
        setupTextField(topText, text: "TOP")
        setupTextField(bottomText, text: "BOTTOM")
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        // Enable the camera button if is supported by the device
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        //move only for bottom text
        if bottomText.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        view.frame.origin.y = +getKeyboardHeight(notification)
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    //UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // When a user taps inside a textfield, the default text should clear.
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // When a user presses return, the keyboard should be dismissed
        textField.resignFirstResponder()
        return true
    }
    
    
    //Utility Functions
    
    //UIImagePickerControllerDelegate Methods
    //implement the method “imagePickerController:didFinishPickingMediaWithInfo:”
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds=true
            //assign the image picked to the UIImageView
            imageView.image = image
            }
        //enable share button
        shareButton.isEnabled = true
        //close the picker
        dismiss(animated: true, completion: nil)
    }
    
   func pickAnImage(_ controlType:UIImagePickerController.SourceType) {

        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = controlType
        present(pickerController, animated: true, completion: nil)
    }
    
    func save() {
            // save the meme
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }
    
    
    func generateMemedImage() -> UIImage {
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    
    //Actions
    

    @IBAction func shareMeme(sender: UIBarButtonItem) {
        //  generate a memed image
        let memedImage = generateMemedImage()
        
        // define an instance of the ActivityViewController
        // pass the ActivityViewController a memedImage as an activity item
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activity.completionWithItemsHandler = {(activity, completed, items, error) in
            if completed {
                self.save()
            }
        }
        
        // present the ActivityViewController
        present(activity, animated: true, completion: nil)
    }
    
    //IBAction to pick up an image from album
    @IBAction func pickAnImageAlbum(_ sender:Any) {
        pickAnImage(.photoLibrary)
    }
    
    //IBAction to pick up an image from camera
    @IBAction func pickAnImageCamera(_ sender:Any) {
        pickAnImage(.camera)
    }
}


    

    
    
