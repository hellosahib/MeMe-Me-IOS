//
//  ViewController.swift
//  MeMe Me
//
//  Created by Sahib on 16/02/18.
//  Copyright © 2018 RTS Production. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    //MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var UIToolBarTop: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextArea: UITextField!
    @IBOutlet weak var bottomTextArea: UITextField!
    @IBOutlet weak var UIToolBar: UIToolbar!
    @IBOutlet weak var shareButton : UIBarButtonItem!
    
    struct Meme {
        var topText : String
        var bottomText : String
        var orignalImage : UIImage
        var EditedImage : UIImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled=false
    topTextArea.defaultTextAttributes=memeTextAttributes
    bottomTextArea.defaultTextAttributes=memeTextAttributes
        topTextArea.textAlignment = .center
        bottomTextArea.textAlignment = .center
    }
    override func viewWillAppear(_ animated: Bool) {
        //This will hide Camera Button if Camera is not there
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    unsubscribeFromKeyboardNotifications()
    }
    
    let memeTextAttributes:[String : Any]=[
        NSAttributedStringKey.strokeColor.rawValue:UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue : UIColor.black,
        NSAttributedStringKey.strokeWidth.rawValue:-5,
    ]
    
    //MARK: CreateAndSaveImage
    
    func saveimage(){
        let meme = Meme(topText: topTextArea.text!, bottomText: bottomTextArea.text!, orignalImage: imageView.image!, EditedImage: generateEditedImage())
    }
    
    func generateEditedImage() -> UIImage {
        //Hiding Navigation Bar And Tool Bar
        
        layoutfit(_test: true)
        //Getting Image
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let editedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //Again Show Toolbar And Navigation Bar
        
        layoutfit(_test: false)
        
        return editedImage
    }
    
    func layoutfit(_test : Bool){
        navigationController?.setNavigationBarHidden(_test, animated: false)
        UIToolBar.isHidden=_test
        UIToolBarTop.isHidden=_test
    }
    
    func initialview(){
        topTextArea.text="TOP"
        bottomTextArea.text="BOTTOM"
        imageView.image=nil
        shareButton.isEnabled=false
        
    }
    
    //MARK: IBAction
    
    @IBAction func saveButton(_ sender: Any) {
        let image = generateEditedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
        
    }
    @IBAction func cancelButton(_ sender: Any) {
        initialview()
    }
    
}
extension ViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //MARK: ViewHeightAdjustment
    //Adjust Height According To Height Of Keyboard
    
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnKeyboardBack), name: .UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self,name: .UIKeyboardWillHide,object:nil)
    }
    
    //This Function Only Works For BottomTextArea
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextArea.isFirstResponder
        {view.frame.origin.y -= getKeyboardHeight(notification)}
    }
    @objc func returnKeyboardBack(){
        if bottomTextArea.isFirstResponder
        {view.frame.origin.y=0}
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    //MARK: ImagePicker
    //Functions To Implement UIImagePickerController For Photos and Camera
    @IBAction func imagePickerAlbum(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.delegate=self
        controller.sourceType = .photoLibrary
        controller.allowsEditing=true
        present(controller, animated: true, completion: nil)
    }
    @IBAction func imagePickerCamera(_sender : Any){
        let controller = UIImagePickerController()
        controller.delegate=self
        controller.sourceType = .camera
        controller.allowsEditing=true
        present(controller, animated: true, completion: nil)
    }
    
    //MARK:ImagePickerCancelled
    //Dismiss the UIImagePicker Controller On Cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //MARK: ImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        print("Hello World")
        shareButton.isEnabled=true
        if let image=info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
            dismiss(animated: true, completion: nil)}
    }
    
}

extension ViewController : UITextFieldDelegate {
    //MARK: TextFieldDelegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text=="TOP" || textField.text=="BOTTOM"
        {textField.text=""}
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

