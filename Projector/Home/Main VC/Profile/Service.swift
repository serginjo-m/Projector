//
//  Service.swift
//  Projector
//
//  Created by Serginjo Melnik on 22/04/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift

//class Service: NSObject {
//    static let shared = Service()
//    
//    let baseUrl = "http://localhost:1440"
//    
//    func handleLogout(completion: @escaping (Result<ApiResponse, Error>) -> ()){
//        
//        //This is just plain urlGET request that receave text plain content type( so it skip wantsJSON)
//        guard let url = URL(string: "http://localhost:1440/api/v1/account/logout") else { return }
//        //this bit tells that you want actually wantsJSON request
//        var logoutRequest = URLRequest(url: url)
//        logoutRequest.httpMethod = "PUT"
//        
//        URLSession.shared.dataTask(with: logoutRequest) { (data, resp, err) in
//            
//            DispatchQueue.main.sync {
//                
//                if let err = err {
//                    print("Failed to login:", err)
//                    return
//                }
//                
//                guard let response = resp as? HTTPURLResponse, response.statusCode == 200 else {
//                    guard let httpUrlResponse = resp as? HTTPURLResponse else {return}
//                    // handle the server error
//                    print("Server status code: \(httpUrlResponse.statusCode)")
//                    return
//                }
//                
//                guard let data = data else {
//                    print("Data error")
//                    return
//                }
//                
//                let apiResponse = ApiResponse(isSuccess: true, message: "Success", returnedData: data)
//                completion(.success(apiResponse))
//            }
//            
//        }.resume() // never forget this resume
//            
//    }
    
//    func handleLogin(email: String, password: String, completion: @escaping (Result<ApiResponse, Error>) -> ()) {
//
//
//        //This is just plain urlGET request that receave text plain content type( so it skip wantsJSON)
//        guard let url = URL(string: "http://localhost:1440/api/v1/entrance/login") else { return }
//        //this bit tells that you want actually wantsJSON request
//        var loginRequest = URLRequest(url: url)
//        loginRequest.httpMethod = "PUT"
//
//        do {
//
//            let params = ["emailAddress": email, "password": password]
//            loginRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
//
//
//            URLSession.shared.dataTask(with: loginRequest) { (data, resp, err) in
//
//                DispatchQueue.main.sync {
//
//                    if let error = err {
//                        // handle the transport error
//                        completion(.failure(error))
//
//                    }
//
//                    guard let response = resp as? HTTPURLResponse, response.statusCode == 200 else {
//                        guard let httpUrlResponse = resp as? HTTPURLResponse else {return}
//                        // handle the server error
//                        print("Server status code: \(httpUrlResponse.statusCode)")
//                        return
//                    }
//
//                    guard let data = data else {
//                        print("Data error")
//                        return
//                    }
//
//                    let apiResponse = ApiResponse(isSuccess: true, message: "Success", returnedData: data)
//                    completion(.success(apiResponse))
//                }
//
//            }.resume() // never forget this resume
//
//        } catch {
//
//            print("Failed to serialize data:", error)
//
//        }
//    }
    
//    func fetchUserProfile(completion: @escaping (Result<UserProfile, Error>) -> ()){
//
//        guard let url = URL(string: "\(baseUrl)/user-profile") else { return }
//
//        var fetchPostsRequest = URLRequest(url: url)
//        fetchPostsRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
//
//        URLSession.shared.dataTask(with: fetchPostsRequest) { (data, resp, err) in
//
//            //go from main queue
//            DispatchQueue.main.async {
//
//
//                if let err = err {
//                    print("Failed to fetch posts:", err)
//                    return
//                }
//
//                guard let data = data else { return }
//
////                print(String(data: data, encoding: .utf8) ?? "")
//
//                do {
//                    let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
//                    completion(.success(userProfile))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//
//        }.resume()
//    }
    
//    func createUser(emailAddress: String, password: String, fullName: String, completion: @escaping (Result<ApiResponse, Error>) -> ()){
//        guard let url = URL(string: "\(baseUrl)/api/v1/entrance/signup") else { return }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//
//        let params = ["emailAddress" : emailAddress, "password": password, "fullName": fullName]
//
//        do{
//
//            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
//            urlRequest.httpBody = data
//            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
//
//            URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
//
//
//                DispatchQueue.main.sync {
//
//                    if let error = err {
//                        // handle the transport error
//                        completion(.failure(error))
//
//                    }
//
//                    guard let response = resp as? HTTPURLResponse, response.statusCode == 200 else {
//                        guard let httpUrlResponse = resp as? HTTPURLResponse else {return}
//                        // handle the server error
//                        print("Server status code: \(httpUrlResponse.statusCode)")
//                        return
//                    }
//
//                    guard let data = data else {
//                        print("Data error")
//                        return
//                    }
//
//                    let apiResponse = ApiResponse(isSuccess: true, message: "Success", returnedData: data)
//                    completion(.success(apiResponse))
//                }
//
//            }.resume()
//
//        }catch{
//            print("Error, when trying to create new user.")
//        }
//    }
    
    //---------------------------- from here starts unused services ---------------------------------------------
//    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> ()) {
//
//        guard let url = URL(string: "\(baseUrl)/home") else { return }
//
//
//        var fetchPostsRequest = URLRequest(url: url)
//        fetchPostsRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
//
//        URLSession.shared.dataTask(with: fetchPostsRequest) { (data, resp, err) in
//
//            //go from main queue
//            DispatchQueue.main.async {
//
//
//                if let err = err {
//                    print("Failed to fetch posts:", err)
//                    return
//                }
//
//                guard let data = data else { return }
//
//                do {
//                    let posts = try JSONDecoder().decode([Post].self, from: data)
//                    completion(.success(posts))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//
//        }.resume()
//    }
    
//    func createPost(title: String, body: String, completion: @escaping (Error?) -> ()) {
//        guard let url = URL(string: "\(baseUrl)/post") else { return }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//
//        let params = ["title": title, "postBody": body]
//        do {
//            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
//
//            urlRequest.httpBody = data
//            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
//
//            URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
//                // check error
//
//                completion(nil)
//
//            }.resume() // i always forget this
//        } catch {
//            completion(error)
//        }
//    }
    
//    func deletePost(id: String, completion: @escaping (Error?) -> ()) {
//        guard let url = URL(string: "\(baseUrl)/post/\(id)") else { return }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "DELETE"
//        URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
//            DispatchQueue.main.async {
//                if let err = err {
//                    completion(err)
//                    return
//                }
//
//                if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
//                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
//                    completion(NSError(domain: "", code: resp.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
//                    return
//                }
//
//                completion(nil)
//
//            }
//
//        }.resume() // i always forget this
//    }
//}
