//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Can Yıldırım on 3.12.2022.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

   
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBarTop : UIToolbar!
    @IBOutlet weak var toolBarBottom : UIToolbar!
    @IBOutlet weak var shareButton : UIBarButtonItem!
    @IBOutlet weak var cancelButton : UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.contentMode = .scaleAspectFill
        topTextField.borderStyle = .none
        bottomTextField.borderStyle = .none
        shareButton.isEnabled = false
        cancelButton.isEnabled = false

        let memeTextAttributes : [NSAttributedString.Key : Any] = [
            
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth : -2.0
       
        ]
     
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotification()
        subscribeToKeyboardNewNotification()
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotification()
        unsubscribeToKeyboardNewNotification()
        
    }
   
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = .none
        cancelButton.isEnabled = false
        
    }
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        
        let pickerControl = UIImagePickerController()
        pickerControl.delegate = self
        present(pickerControl, animated: true, completion: nil)
  
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        
        let pickerControl = UIImagePickerController()
        pickerControl.delegate = self
        pickerControl.sourceType = .camera
        present(pickerControl, animated: true, completion: nil)
        
    }

    func generateMemedImage() -> UIImage {
        
        toolBarBottom.isHidden = true
        toolBarTop.isHidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        toolBarTop.isHidden = false
        toolBarBottom.isHidden = false
   
        return memedImage
       
    }
    
    @IBAction func activityView(_ sender: UIBarButtonItem) {
        
        let memedImage = generateMemedImage()
        
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in

            guard completed != false else {return}

            if let activity = activityType {

                switch activity {

                case .saveToCameraRoll :
                
                    let alertController = UIAlertController(title: "", message: "Image has been saved!", preferredStyle: UIAlertController.Style.alert)
                    let actionAlert = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alertController.addAction(actionAlert)
                    self.present(alertController, animated: true, completion: nil)
                    
                default : return

                }

            }

        }
    
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imagePickerView.image = image
            
        }
        
        dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if topTextField.isEditing {
            
            topTextField.text = ""
            
        } else {
            
            bottomTextField.text = ""
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        cancelButton.isEnabled = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        
        if topTextField.isEditing {
       
        view.frame.origin.y = -getKeyboardHeight(notification)
        view.frame.origin.y = -topTextField.frame.height
        
        } else {
        
        view.frame.origin.y = -getKeyboardHeight(notification)
            
        }
        
    }
   
    @objc func keyboardWillHide(_ notification : Notification) {
        
        view.frame.origin.y = 0
        
    }
    
    func getKeyboardHeight(_ notification : Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
        
    }
    
    func subscribeToKeyboardNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    func unsubscribeToKeyboardNotification() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    func subscribeToKeyboardNewNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNewNotification() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


