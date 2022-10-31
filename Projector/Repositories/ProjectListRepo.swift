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
    
    func getProjectSteps() -> Results<ProjectStep> {
        return realm.objects(ProjectStep.self)
    }
    
    func getProjectStep(id: String) -> ProjectStep? {
        return realm.object(ofType: ProjectStep.self, forPrimaryKey: id)
    }
    
    func updateStepCategory(category: String, step: ProjectStep){
        try! realm.write {
            step.category = category
        }
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
            realm.add(list, update: Realm.UpdatePolicy.modified)
        })
    }
    
    func updateProjectFilterStatus(project: ProjectList, filterIsActive: Bool) {
        try! self.realm.write({
            project.filterIsActive = filterIsActive
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
    
    func updateStepProgressStatus(step: ProjectStep, status: String) {
        try! self.realm.write({
            step.category = status
        })
    }
    func updateStepEvent(step: ProjectStep, event: Event){
        try! self.realm.write({
            step.event = event
        })
    }
    
    func updateStepDisplayedStatus(step: ProjectStep, displayedStatus: Bool){
        try! self.realm.write({
            step.displayed = displayedStatus
        })
    }
    
    func updateStepSection(step: ProjectStep, section: StepWaySection){
        try! self.realm.write({
            step.section = section
        })
    }
    
    //edit step function
    func editStep(step: ProjectStep){
        try! self.realm.write({
            realm.add(step, update: Realm.UpdatePolicy.modified)
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
    
    func deleteStepFromProject(list: ProjectList, stepAtIndex: Int){
        try! realm.write ({
            //projectDetail?.projectStep.remove(at: indexPath.row)
            list.projectStep.remove(at: stepAtIndex)
        })
    }
    
    func deleteStep(step: ProjectStep){
        try! realm.write({
            realm.delete(step)
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
            realm.add(event, update: Realm.UpdatePolicy.modified)
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
    
    
    func getEvent(id: String) -> Event? {
        return realm.object(ofType: Event.self, forPrimaryKey: id)
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
    
    func getCanvasNote(id: String) -> CanvasNote? {
        return realm.object(ofType: CanvasNote.self, forPrimaryKey: id)
    }
    
    func updateCanvasUrl(url: String, note: CanvasNote){
        try! self.realm.write({
            note.imageUrl = url
        })
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
    
    func updateNotificationCompletionStatus(notification: Notification, isComplete: Bool) {
        try! self.realm.write({
            notification.complete = isComplete
        })
    }
    
    //create Notification
    func createNotification(notification: Notification){
        try! realm.write ({
            realm.add(notification)
        })
    }
    
    //update an event object
    func updateNotification(notification: Notification){
        try! realm.write ({
            realm.add(notification, update: Realm.UpdatePolicy.modified)
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
    
    //create user
    func createUser(user: User){
        try! realm.write ({
            realm.add(user)
        })
    }
    
    func getAllUsers() -> Results<User> {
        return realm.objects(User.self)
    }
    
    func deleteUser(user: User){
        try! realm.write ({
            realm.delete(user)
        })
    }
    
    func updateUserStatus(isLogined: Bool, user: User){
        try! realm.write {
            user.isLogined = isLogined
        }
    }
    
    //create holiday object
    func createHoliday(holidayEvent: HolidayEvent){
        try! realm.write ({
            realm.add(holidayEvent)
        })
    }
    
    func getHolidays() -> Results<HolidayEvent> {
        return realm.objects(HolidayEvent.self)
    }
    
    func deleteHoliday(holiday: HolidayEvent){
        try! realm.write ({
            realm.delete(holiday)
        })
    }
    
    //step way section
    func createSection(section: StepWaySection){
        try! realm.write ({
            realm.add(section)
        })
    }
    
    func getAllStepSections() -> Results<StepWaySection> {
        return realm.objects(StepWaySection.self)
    }
    
    func deleteSection(section: StepWaySection){
        try! realm.write ({
            realm.delete(section)
        })
    }
    
    func updateSectionIndex(indexNumber: Int, section: StepWaySection){
        try! realm.write {
            section.indexNumber = indexNumber
        }
    }
    
    func updateSectionName(name: String, section: StepWaySection){
        try! realm.write {
            section.name = name
        }
    }
}
