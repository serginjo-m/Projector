//
//  HolidayRequest.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.09.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation

struct HolidayRequest {
    let resourceURL:URL
    let API_KEY = "6faaaa836992dc701a69013a75b46e2808526188"
    
    init(countryCode:String) {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        let currentYear = format.string(from: date)
        
        let resourceString = "https://calendarific.com/api/v2/holidays?api_key=\(API_KEY)&country=\(countryCode)&year=\(currentYear)"
        
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    
    
    //once we have information, completion closure calls
    //escaping calls after func returns
    func getHolidays(completion: @escaping([HolidayDetail]) -> Void){
        //receive data, response, error
        //this all happens assincr (not in main thread), because it takes some time to get inform from web
        let dataTask = URLSession.shared.dataTask(with: resourceURL){data, _, _ in
            //check if we actually received data
            guard let jsonData = data else {
                print("No Data Available")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let holidayResponse = try decoder.decode(HolidayResponse.self, from: jsonData)
                let holidayDetails = holidayResponse.response.holidays
                completion(holidayDetails)
            }catch let jsonErr {
                print("Failed to decode json:", jsonErr)
            }
        }
        dataTask.resume()
    }
}
