# test

//
//  CreateChatRoomViewController.swift
//


import UIKit
import FirebaseAuth

class CreateChatRoomViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
let imagePicker = UIImagePickerController()
    @IBOutlet weak var photoImage: UIImageView!
   
    @IBOutlet weak var roomName: UITextField!
    
  
    
    var selectedPhoto : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "EDIT PROFILE"
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(tap:)))
        tap.numberOfTapsRequired = 1
        photoImage.addGestureRecognizer(tap)
     
        photoImage.clipsToBounds = true
        
        if let user = DataService.dataService.currentUser{
                      if user.photoURL != nil {
                if let data = NSData(contentsOf: user.photoURL!){
                    self.photoImage!.image = UIImage.init(data: data as Data)
                }
            }
        }else{
            //No user is signed in
        }
    }
    func selectPhoto(tap: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
        }else {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        self.photoImage.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
}
    
    
    @IBAction func doneCreatingRoomButton(_ sender: UIButton) {
        var data: NSData = NSData()
        data = UIImageJPEGRepresentation(photoImage.image!, 0.1)! as NSData
        DataService.dataService.CreateRoom(user: FIRAuth.auth()!.currentUser!,roomName: roomName.text!, data: data)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
