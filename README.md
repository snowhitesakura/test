# test

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class DataService{
    
    static let dataService = DataService()
    
    private var _BASE_REF = FIRDatabase.database().reference(fromURL: "my db")

    private var _ROOM_REF = FIRDatabase.database().reference(fromURL: "my db").child("rooms")
    
 
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    
    var ROOM_REF: FIRDatabaseReference {
        return _ROOM_REF
    }
    
    var currentUser: FIRUser?{
        return FIRAuth.auth()!.currentUser
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var fileUrl: String!
    
    
    
    func fetchDataFromServer(callback: @escaping (Room) -> ()){
        DataService.dataService.ROOM_REF.observe(.childAdded, with: {(snapshot) in
            
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! Dictionary<String, AnyObject>)
            callback(room)
        }
        
        )
        
    }
    
    
    func SignUp(username: String, email: String, password: String, data: NSData) {
        FIRAuth.auth()?.createUser(withEmail: email, password:password, completion: {(user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let changeRequest = user?.profileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }}
                )
            let filePath = "profileImage/\(user!.uid)"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            self.storageRef.child(filePath).put(data as Data, metadata: metadata, completion: {(metadata, error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                self.fileUrl = metadata?.downloadURLs![0].absoluteString
                let changeRequestPhoto = user!.profileChangeRequest()
                changeRequestPhoto.photoURL = NSURL(string: self.fileUrl)! as URL
                changeRequestPhoto.commitChanges(completion: {(error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }else{
                        print("Profile Updated")
                    }
                })
                

                self._BASE_REF.child("users").child((user?.uid)!).setValue(["username": username])
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
             appDelegate.logIn()
            
    })
    })
    
}
    
    
    func CreateRoom(user:FIRUser, roomName: String, data: NSData){
        let filePath = "\(user.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).put(data as Data, metadata:metaData){ (metadata, error) in
            if let error = error {
                print("Error")
                return
            }
            self.fileUrl = metadata!.downloadURLs![0].absoluteString
            if let user = FIRAuth.auth()?.currentUser {
                let idRoom = self.BASE_REF.child("rooms").childByAutoId()
                idRoom.setValue(["roomName": roomName, "thumbaniUrlFromStorage":self.storageRef.child(metadata!.path!).description, "fileUrl": self.fileUrl])
            }
        
        }
    }
    
    func logIn(email: String, password: String){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {(user, error)in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logIn()
        } )
        
        
    }
    
    func logout(){
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let logInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC")
            UIApplication.shared.keyWindow?.rootViewController = logInVC
        }
        catch let signOutError as NSError{
            print("Error signing out")
        }
    }
    
    func SaveProfile(username: String, email: String, data: NSData){
        let user = FIRAuth.auth()?.currentUser!
        let filePath = "\(user!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        self.storageRef.child(filePath).put(data as Data, metadata: metaData) {(metadata, error)in
            if error != nil {
                print("Error")
                return
            }
            self.fileUrl = metadata!.downloadURLs![0].absoluteString
            let changeRequestProfile = user?.profileChangeRequest()
            changeRequestProfile?.photoURL = NSURL(string: self.fileUrl)! as URL
            changeRequestProfile?.displayName = username
            changeRequestProfile?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }else {
                    
                }
            })
            
            if let user = user {
                user.updateEmail(email, completion: { (error)in
                    if let error = error {
                        print(error.localizedDescription)
                    }else {
                        print("email update")
                    }
                })
            
            }
            
            
        }
    }
    
        
}
