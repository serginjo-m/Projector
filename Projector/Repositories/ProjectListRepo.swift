//
//  ProjectListRepository.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.01.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift

class ProjectListRepository {
    private var realm: Realm!
    
    private init (){//initializer
        try! realm = Realm()
    }

    static let instance = ProjectListRepository()//initializer
    
    
    func getProjectLists() -> Results<ProjectList> {
        return realm.objects(ProjectList.self)
    }
    
    func getProjectList(id: String) -> ProjectList? {
        return realm.object(ofType: ProjectList.self, forPrimaryKey: id)
    }
    
    func getProjectStep(id: String) -> ProjectStep? {
        return realm.object(ofType: ProjectStep.self, forPrimaryKey: id)
    }
    
    //here we actualy add a new object
    // list: - is a param & can have any name
    func createProjectList(list: ProjectList){
        try! realm.write ({
            realm.add(list)
        })
    }

    //update - project
    func updateProjectList(list: ProjectList){
        try! realm.write ({
            realm.add(list, update: true)
        })
    }
    
    func updateProjectName(name: String, list: ProjectList){
        try! realm.write {
            list.name = name
        }
    }
    
    func updateStepCompletionStatus(step: ProjectStep, isComplete: Bool) {
        try! self.realm.write({
            step.complete = isComplete
        })
    }
    //edit step function
    func editStep(step: ProjectStep){
        try! self.realm.write({
            realm.add(step, update: true)
        })
    }
    
    func deleteProjectList(list: ProjectList){
        try! realm.write ({
            //this will also remove all ProjectStep objects from data Base
            for step in list.projectStep {
                realm.delete(step)
            }
            
            realm.delete(list)
        })
    }
    
    func deleteProjectStep(list: ProjectList, stepAtIndex: Int){
        try! realm.write ({
            //projectDetail?.projectStep.remove(at: indexPath.row)
            list.projectStep.remove(at: stepAtIndex)
        })
    }
    
    func deleteStepItem(step: ProjectStep, itemAtIndex: Int){
        try! realm.write ({
            step.itemsArray.remove(at: itemAtIndex)
        })
    }
    
    //create an event object
    func createEvent(event: Event){
        try! realm.write ({
            realm.add(event)
        })
    }
    
    //update an event object
    func updateEvent(event: Event){
        try! realm.write ({
            realm.add(event, update: true)
        })
    }
    
    func deleteEvent(event: Event){
        try! realm.write ({
            realm.delete(event)
        })
    }
    
    func getEvents() -> Results<Event> {
        return realm.objects(Event.self)
    }
    
    //create an event object
    func createDayActivity(dayActivity: DayActivity){
        try! realm.write ({
            realm.add(dayActivity)
        })
    }
    
    func getDayActivities() -> Results<DayActivity> {
        return realm.objects(DayActivity.self)
    }
    
    func appendNewItemToDayActivity(dayActivity: DayActivity, userActivity: UserActivity) {
        try! self.realm!.write ({//here we actualy add a new object called userActivity
            dayActivity.userActivities.append(userActivity)
        })
    }
    
    //create camera note
    func createCameraNote(cameraNote: CameraNote){
        try! realm.write ({
            realm.add(cameraNote)
        })
    }
    
    func getCameraNotes() -> Results<CameraNote> {
        return realm.objects(CameraNote.self)
    }
    
    func deleteCameraNote(note: CameraNote){
        try! realm.write ({
            realm.delete(note)
        })
    }
    
    func createCanvasNote(canvasNote: CanvasNote){
        try! realm.write ({
            realm.add(canvasNote)
        })
    }
    
    func getCanvasNotes() -> Results<CanvasNote> {
        return realm.objects(CanvasNote.self)
    }
    
    func deleteCanvasNote(note: CanvasNote){
        try! realm.write ({
            realm.delete(note)
        })
    }
    
    //create TextNote note
    func createTextNote(textNote: TextNote){
        try! realm.write ({
            realm.add(textNote)
        })
    }
    
    func getTextNotes() -> Results<TextNote> {
        return realm.objects(TextNote.self)
    }
    
    func deleteTextNote(textNote: TextNote){
        try! realm.write ({
            realm.delete(textNote)
        })
    }
    
    func getStatisticNotes() -> Results<StatisticData> {
        return realm.objects(StatisticData.self)
    }
    
    func deleteStatisticNote(note: StatisticData){
        try! realm.write ({
            realm.delete(note)
        })
    }
    
    //create Notification
    func createNotification(notification: Notification){
        try! realm.write ({
            realm.add(notification)
        })
    }
    
    func getNotificationNotes() -> Results<Notification> {
        return realm.objects(Notification.self)
    }
    
    func deleteNotificationNote(note: Notification){
        try! realm.write ({
            realm.delete(note)
        })
    }
    
    func getNotification(id: String) -> Notification? {
        return realm.object(ofType: Notification.self, forPrimaryKey: id)
    }
}
