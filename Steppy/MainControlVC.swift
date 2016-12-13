//
//  SecondVC.swift
//  Steppy
//
//  Created by Steven Lee on 9/15/16.
//  Copyright © 2016 Steven Lee, Jack Meyers, Robert Sepovida.. All rights reserved.
//

import UIKit
import SQLite
import HealthKit
import SAConfettiView


var chartType = 0;
var curSteps = 0;
var curHR = 0;

class SecondVC: UIViewController {
    // Locals
    let healthKitStore = HKHealthStore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = _backgroundColor
        print("Second VC Loaded")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(toInfoPage))
        
        enableHealthKit()
        
        getStepsFromHealthKit()
        getHeartRateFromHealthKit()
        
        
        let buttonOne = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width/2, height: view.frame.height/2)) // Heart Rate
        let buttonTwo = UIButton(frame: CGRect(x: view.frame.width/2, y: 0, width: view.frame.width/2, height: view.frame.height/2)) // Weight
        let buttonThree = UIButton(frame: CGRect(x: 0, y: view.frame.height/2, width: view.frame.width/2, height: view.frame.height/2)) // Steps
        let buttonFour = UIButton(frame: CGRect(x: view.frame.width/2, y: view.frame.height/2, width: view.frame.width/2, height: view.frame.height/2)) // Compare
        let buttonFive = UIButton(frame: CGRect(x: (view.frame.width/2)-50, y: (view.frame.width/2)+100, width: 100, height: 100)) // Add Data
        
        buttonOne.backgroundColor = _backgroundColor
        buttonTwo.backgroundColor = _backgroundColor
        buttonThree.backgroundColor = _backgroundColor
        buttonFour.backgroundColor = _backgroundColor
        buttonFive.backgroundColor = _backgroundColor
        
        
        buttonOne.layer.borderWidth = 3
        buttonOne.layer.borderColor = _fontColor.cgColor
        
        buttonTwo.layer.borderWidth = 3
        buttonTwo.layer.borderColor = _fontColor.cgColor
        
        buttonThree.layer.borderWidth = 3
        buttonThree.layer.borderColor = _fontColor.cgColor
        
        buttonFour.layer.borderWidth = 3
        buttonFour.layer.borderColor = _fontColor.cgColor
        
        buttonFive.layer.borderWidth = 3
        buttonFive.layer.cornerRadius = 5
        buttonFive.layer.borderColor = _fontColor.cgColor
        
        buttonOne.addTarget(self, action: #selector(displayChart(sender:)), for: .touchUpInside)
        buttonOne.tag = 1
        
        buttonTwo.addTarget(self, action: #selector(displayChart(sender:)), for: .touchUpInside)
        buttonTwo.tag = 2
        
        buttonThree.addTarget(self, action: #selector(displayChart(sender:)), for: .touchUpInside)
        buttonThree.tag = 3
        
        buttonFour.addTarget(self, action: #selector(displayDataTable(sender:)), for: .touchUpInside)
        buttonFive.addTarget(self, action: #selector(addData(sender:)), for: .touchUpInside)
        
        buttonOne.setTitle("S T E P S", for: .normal)
        buttonOne.setTitleColor(_fontColor, for: .normal)
        
        buttonTwo.setTitle("W E I G H T", for: .normal)
        buttonTwo.setTitleColor(_fontColor, for: .normal)
        
        buttonThree.setTitle("H E A R T  R A T E", for: .normal)
        buttonThree.setTitleColor(_fontColor, for: .normal)
        
        buttonFour.setTitle("D A T A", for: .normal)
        buttonFour.setTitleColor(_fontColor, for: .normal)
        
        buttonFive.setTitle("A D D", for: .normal)
        buttonFive.setTitleColor(_fontColor, for: .normal)
        
        
        view.addSubview(buttonTwo)
        view.addSubview(buttonFour)
        view.addSubview(buttonOne)
        view.addSubview(buttonThree)
        view.addSubview(buttonFive)
        self.view.makeToast("Welcome \(username), let's get fit!", duration: 3.0, position: .top)
        
    }
    
    
    func findData() -> Bool {
        return false;
    }
    
    func addData(sender:UIButton){
        let alertController = UIAlertController(title: "New Data", message: "", preferredStyle: .alert)
        
        // Email
        alertController.addTextField { (textField) in
            textField.placeholder = "Date (yyyy-MM-dd)"
            let date = NSDate()
            let myLocale = Locale(identifier: "bg_BG")
            let formatter = DateFormatter()
            formatter.locale = myLocale
            formatter.dateStyle = .medium
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = myLocale
            let dateComponents = calendar.dateComponents([.day, .month, .year], from: date as Date)
            textField.text = "\(dateComponents.day!)-\(dateComponents.month!)-\(dateComponents.year!)"
            
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Heart Rate"
            if (curHR != 0){
                textField.text = String(curHR)
            }
            textField.keyboardType = .decimalPad
        }
        // Password
        alertController.addTextField { (textField) in
            textField.placeholder = "Weight"
            textField.keyboardType = .decimalPad
            textField.text = String(globalWeight)
            
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Steps"
            if (curSteps != 0){
                textField.text = String(curSteps)
            }
            textField.keyboardType = .decimalPad
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            //let destination = AAPLEnergyViewController() // Your destination
            //self.navigationController?.pushViewController(destination, animated: true)
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            // Add To Data
            let udate = alertController.textFields?[0].text
            let hr = Int64((alertController.textFields?[1].text!)!)
            let wei = Double((alertController.textFields?[2].text)!)
            let ste = Int64((alertController.textFields?[3].text)!)
            // Format Date
            var check = true
            if(udate == "" || hr == nil || wei == nil || ste == nil){
                check = false
            }
            
            let alice = users.filter(email == username)
            if(wei != Double(globalWeight)){
                do {
                    if try db.run(alice.update(weight <- Int64(wei!))) > 0 {
                        print("updated alice")
                        globalWeight = Int(wei!)
                    } else {
                        print("alice not found")
                    }
                } catch {
                    print("update failed: \(error)")
                }
            }
            
            // Check if date is in the future
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let dateDED = dateFormatter.date(from: udate!)
            
            if (dateDED?.compare(NSDate() as Date) == ComparisonResult.orderedDescending) {
                self.view.makeToast("That has not happened yet!", duration: 3.0, position: .top)
            } else if check {
                try! self.addHealthData(udate: udate!, wei: wei!, hr: hr!, ste: ste!)
                
            } else {
                self.view.makeToast("You forgot some data!", duration: 3.0, position: .top)
            }
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func addHealthData(udate:String,wei:Double,hr:Int64,ste:Int64){
        if(hr >= 60 && hr <= 300){
            if(udate.characters.count == 10){
                let insert = health.insert(uId <- username, date <- udate, uWeight <- wei, heartRate <- hr, steps <- ste)
                try! db.run(insert)
                self.view.makeToast("Added!", duration: 3.0, position: .top)
                let confettiView = SAConfettiView(frame: self.view.bounds)
                self.view.addSubview(confettiView)
                confettiView.confettiOnTimer(sec: 4)
            }
            else{
                self.view.makeToast("Enter a Valid Date DD-MM-YYYY", duration: 3.0, position: .top)
            }

            
        }
        else{
            self.view.makeToast("Heart Rate Should Be Between 60-300!", duration: 3.0, position: .top)
        }
        
    }
    
    func displayDataTable(sender:UIButton){
        let destination = DataTableVC() // Your destination
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func displayChart(sender:UIButton){
        chartType = sender.tag
        let destination = ChartVC() // Your destination
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func enableHealthKit() {
        //var shareTypes = Set<HKSampleType>()
        //shareTypes.insert(HKSampleType.workoutType())
        
        var readTypes = Set<HKObjectType>()
        readTypes.insert(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        readTypes.insert(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
        // readTypes.insert(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!)
        
        healthKitStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) -> Void in
            if success {
                print("success")
            } else {
                print("failure")
            }
            
            if let error = error { print(error) }
        }
    }
    
    func getStepsFromHealthKit () {
        if(HKHealthStore.isHealthDataAvailable())
        {
            // Add your HealthKit code here
            
            let calendar = Calendar.current
            let twoDaysAgo = calendar.date(byAdding: .day, value: -1, to: Date())
            let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
            let startDate = twoDaysAgo
            let interval = NSDateComponents()
            interval.day = 1
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate! as Date, end: NSDate() as Date, options: .strictStartDate)
            //Steps
            let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: NSDate() as Date, intervalComponents:interval as DateComponents)
            
            query.initialResultsHandler = { query, results, error in
                let endDate = NSDate()
                let startDate = twoDaysAgo!
                if let myResults = results{
                    myResults.enumerateStatistics(from: startDate as Date, to: endDate as Date) {
                        statistics, stop in
                        if let quantity = statistics.sumQuantity() {
                            //let date = statistics.startDate
                            let stepz = quantity.doubleValue(for: HKUnit.count())
                            print("\(date): steps = \(stepz)")
                            curSteps = Int(stepz)
                        }
                    }
                }
            }
            
            healthKitStore.execute(query)
        }
    }
    
    func toInfoPage(sender:UIButton){
        let destination = ProfileVC() // Your destination
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func getHeartRateFromHealthKit () {
        // on load
        if(HKHealthStore.isHealthDataAvailable())
        {
            // Add your HealthKit code here
            let calendar = Calendar.current
            let twoDaysAgo = calendar.date(byAdding: .day, value: -1, to: Date())
            let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
            let startDate = twoDaysAgo
            let interval = NSDateComponents()
            interval.day = 1
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate! as Date, end: NSDate() as Date, options: .strictStartDate)
            //Steps
            let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .discreteAverage, anchorDate: NSDate() as Date, intervalComponents:interval as DateComponents)
            
            query.initialResultsHandler = { query, results, error in
                let endDate = NSDate()
                let startDate = twoDaysAgo!
                if let myResults = results{
                    myResults.enumerateStatistics(from: startDate as Date, to: endDate as Date) {
                        statistics, stop in
                        if let quantity = statistics.averageQuantity() {
                            //let date = statistics.startDate
                            let stepz = quantity.doubleValue(for: HKUnit(from: "count/min"))
                            print("\(date): steps = \(stepz)")
                            curHR = Int(stepz)
                        }
                    }
                }
            }
            
            healthKitStore.execute(query)
            print("got here")
            
        }
        
    }
    
    
    
}
