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

enum UserDeletionError: Error {
    case userNotAuthenticated
    case genericError(error: String)
}

enum UserForgotPasswordError: Error {
    case genericError(error: String)
}

class FirebaseService: NSObject {
        
    static let shared = FirebaseService()

    var ref: DatabaseReference?
    
    override init() {
        self.ref = Database.database(url: "https://projectorfirebase-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    }
    
    func handleLogin(email: String, password: String, completionHandler: @escaping () -> Void ){
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            
            if error != nil {
                print("We have an error: ", error as Any)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid, let gloabalReference = self.ref else{
                return
            }
            
            gloabalReference.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    
                    if let name = dictionary["name"] as? String, let email = dictionary["email"] as? String {
                        let user = User()
                        user.name = name
                        user.email = email
                        user.id = uid
                        user.isLogined = true
                        
                        ProjectListRepository.instance.createUser(user: user)
                        completionHandler()
                    }
                }
                
            }, withCancel: nil)
            
        }
        
    }
    
    func deleteUserAccount(completionHandler: @escaping (UserDeletionError?) -> Void){
        
        guard let user = Auth.auth().currentUser else {
            completionHandler(.userNotAuthenticated)
            return
        }
        
        user.delete { error in
            
            if let error = error {
                completionHandler(.genericError(error: error.localizedDescription))
            }else{
                
                let users = ProjectListRepository.instance.getAllUsers()
                
                for user in users {
                    ProjectListRepository.instance.deleteUser(user: user)
                }

                completionHandler(nil)
            }
        }
    }
    
    func handleForgotPasswordEmail(email: String, completionHandler: @escaping (UserForgotPasswordError?) -> Void){
        
        let auth = Auth.auth()
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                
                completionHandler(.genericError(error: error.localizedDescription))
            }else{
                
                completionHandler(nil)
            }
        }
    }
    
    func handleRegister(name: String, email: String, password: String, completionHandler: @escaping () -> Void ){
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
        
            if error != nil {
                print("this is error: ", error as Any)
                return
            }
            
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

                ProjectListRepository.instance.createUser(user: userProfile)
                completionHandler()
            }
        }
    }
    
    func handleLogout(completionHandler: @escaping () -> Void){

        do {
            try Auth.auth().signOut()
        } catch let logoutError{
            print("logout error: ", logoutError)
        }
        
        let users = ProjectListRepository.instance.getAllUsers()
        
        for user in users {
            ProjectListRepository.instance.deleteUser(user: user)
        }
        
        completionHandler()
    }
    
    
}
