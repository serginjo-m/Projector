//
//  FirebaseService.swift
//  Projector
//
//  Created by Serginjo Melnik on 24/09/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage



class FirebaseService: NSObject {
        
    static let shared = FirebaseService()

    //hold reference to Firebase database
    var ref: DatabaseReference?
    
    override init() {
        self.ref = Database.database(url: "https://projectorfirebase-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    }
    
    func handleLogin(email: String, password: String, completionHandler: @escaping () -> Void ){
        
        //Firebase Login function
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            
            if error != nil {
                print("We have an error: ", error as Any)
                return
            }
            

            //unique user identifier
            guard let uid = Auth.auth().currentUser?.uid, let gloabalReference = self.ref else{
                //for some reason uid is nil here
                return
            }
            
            
            //bacause I've did an error at the installation, I need to specify a url at the begining
            gloabalReference.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
                //convert value to usable dictionary
                if let dictionary = snapshot.value as? [String: Any] {
                    
                    
                    if let name = dictionary["name"] as? String, let email = dictionary["email"] as? String {
                        let user = User()
                        user.name = name
                        user.email = email
                        user.id = uid
                        user.isLogined = true
                        
                        //It is not the best solution but for this purpose it will be alright
                        //So the plan is when logged in, create user and delete when logout
                        ProjectListRepository.instance.createUser(user: user)
                        completionHandler()
                    }
                }
                
            }, withCancel: nil)
            
        }
        
    }
    
    func handleRegister(name: String, email: String, password: String, completionHandler: @escaping () -> Void ){
        
        //Firebase create user method
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            //if returns error, exits from function
            if error != nil {
                print("this is error: ", error as Any)
                return
            }
            
            
            //successfully authenticated user
            
            guard let uid = result?.user.uid, let ref = self.ref else {return}
            
            let usersReference = ref.child("users").child(uid)
            
            let values = ["name": name, "email": email]
            
            
            usersReference.updateChildValues(values) { error, ref in
                
                if error != nil {
                    print(error as Any)
                    return
                }
                
                let userProfile = User()
                userProfile.name = name
                userProfile.email = email
                userProfile.id = uid
                userProfile.isLogined = true

                //It is not the best solution but for this purpose it will be alright
                //So the plan is when logged in, create user and delete when logout
                ProjectListRepository.instance.createUser(user: userProfile)
                completionHandler()
            }
        }
    }
    
    func handleLogout(completionHandler: @escaping () -> Void){
        //try to logout
        do {
            
            try Auth.auth().signOut()

        } catch let logoutError{
            print("logout error: ", logoutError)
        }
        
        //It is not the best solution but for this purpose it will be alright
        //So the plan is when logged in create user and delete when logout
        let users = ProjectListRepository.instance.getAllUsers()
        //delete from database
        for user in users {
            ProjectListRepository.instance.deleteUser(user: user)
        }
        
        completionHandler()
       
    }
    
    
}
