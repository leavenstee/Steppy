//
//  ViewController.swift
//  steppy2.0
//
//  Created by Steven Lee on 9/22/16.
//  Copyright © 2016 Steven Lee, Jack Meyers, Robert Sepovida.. All rights reserved.
//
import UIKit
import SQLite
import CryptoSwift
import UserNotifications


///////////////
// DATA BASE //
///////////////
// Database
let path = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    ).first!
let db = try! Connection("\(path)/database.db")


// User
let users = Table("users")
let email = Expression<String>("email")
let fName = Expression<String>("fName")
let lName = Expression<String?>("lName")
let height = Expression<Int64>("height")
let weight = Expression<Int64>("weight")
let sex = Expression<String>("sex")
let age = Expression<Int64>("age")
let password = Expression<String>("password")

// Health Things
let health = Table("health")
let id = Expression<Int64>("id")
let uId = Expression<String>("fid")
let date = Expression<String>("date")
let uWeight = Expression<Double>("uWeight")
let steps = Expression<Int64>("steps")
let heartRate = Expression<Int64>("heartRate")



//////////////////
// COLOR SCHEME //
//////////////////
let _fontColor = UIColor(red:0.05, green:0.28, blue:0.38, alpha:1.0)
let _accentColor = UIColor(red:0.62, green:0.96, blue:0.81, alpha:1.0)
let _backgroundColor = UIColor(red:0.96, green:0.93, blue:0.93, alpha:1.0)

/////////////
// USER //
//////////
var username = ""
var pass = ""
var globalWeight = 0
var centerX: CGFloat!
var centerY: CGFloat!
var avgHRData = 0
var avgStepData = 0
class ViewController: UIViewController {
    ///////////
    //GLOBALS//
    ///////////
    
    
    
    // Buttons //
    var loginBtn: UIButton!
    var createBtn: UIButton!
    // Label //
    var headerLbl: UILabel!
    var welcomeLbl: UILabel!
    ///////////////////
    // VIEW DID LOAD //
    ///////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // find db print out the path
        print("\(path)/database.db")
        
        //DB
        createTables()
        
        // Setbackground color
        view.backgroundColor = _backgroundColor;
        
        // Nav bar
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.isTranslucent = true
        
        // INIT Views
        centerX = view.frame.width/2
        centerY = view.frame.height/2
        
        // INIT Labels
        headerLbl = UILabel(frame: CGRect(x: centerX-40, y: centerY-centerY/4, width: 100, height: 100))
        headerLbl.text = "S T E P P Y"
        headerLbl.textColor = _fontColor
        view.addSubview(headerLbl)
        
        // INIT Buttons
        // - LOGIN
        loginBtn = UIButton(frame: CGRect(x: centerX-50, y: centerY+centerY/4, width: 100, height: 50))
        loginBtn.setTitle("Login", for: UIControlState())
        loginBtn.setTitleColor(UIColor.gray, for: UIControlState())
        loginBtn.addTarget(self, action: #selector(tryLogin(_:)), for: .touchUpInside)
        view.addSubview(loginBtn)
        // - CREATE
        createBtn = UIButton(frame: CGRect(x: centerX-50, y: centerY+centerY/4+centerY/4, width: 100, height: 50))
        createBtn.setTitle("New User", for: UIControlState())
        createBtn.setTitleColor(UIColor.gray, for: UIControlState())
        createBtn.addTarget(self, action: #selector(addNewUser(_:)), for: .touchUpInside)
        view.addSubview(createBtn)
        
        // Welcome Back Label
        var userFNAME = ""
        for user in try! db.prepare(users) {
            print("id: \(user[email]), name: \(user[fName])")
            username = user[email]
            userFNAME = user[fName]
            // try login returning user
            pass = user[password]
            globalWeight = Int(user[weight])
            //print (pass)
            autoLogin()
            
        }
        if (userFNAME != ""){
            welcomeLbl = UILabel(frame: CGRect(x: centerX-70, y: centerY-centerY/6, width: 300, height: 100))
            welcomeLbl.text = "Welcome Back \(userFNAME)"
            welcomeLbl.textColor = _fontColor
            view.addSubview(welcomeLbl)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //////////////////
    // Add New User //
    //////////////////
    
    func addNewUser(_ sender:UIButton){
        let alertController = UIAlertController(title: "New User", message: "", preferredStyle: .alert)
        // First Name
        alertController.addTextField { (textField) in
            textField.placeholder = "First Name"
            
        }
        // Last Name
        alertController.addTextField { (textField) in
            textField.placeholder = "Last Name"
        }
        // Email
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        // Height
        alertController.addTextField { (textField) in
            textField.placeholder = "Height (in.)"
            textField.keyboardType = .phonePad
        }
        // Weight
        alertController.addTextField { (textField) in
            textField.placeholder = "Weight (lbs)"
            textField.keyboardType = .phonePad
        }
        // Sex
        alertController.addTextField { (textField) in
            textField.placeholder = "Male or Female (M or F)"
        }
        // Age
        alertController.addTextField { (textField) in
            textField.placeholder = "Age"
            textField.keyboardType = .phonePad
        }
        // Password
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            var useTaken = false;
            //Error Check
            for user in try! db.prepare(users) {
                if (user[email] == (alertController.textFields?[2].text!)!) {
                    useTaken = true;
                }
            }
            
            // Error
            if(!useTaken){
                self.addNewUserDB(_first: (alertController.textFields?[0].text!)!,_last: (alertController.textFields?[1].text!)!,_email: (alertController.textFields?[2].text!)!,_height: Int64((alertController.textFields?[3].text)!)!,_weight: Int64((alertController.textFields?[4].text)!)!, _password: (alertController.textFields?[7].text)!, _age: Int64((alertController.textFields?[6].text)!)!,_sex: (alertController.textFields?[5].text!)!)
            } else {
                self.view.makeToast("\(alertController.textFields?[2].text!)!), taken!", duration: 3.0, position: .top)
            }
            
            
            username = (alertController.textFields?[2].text!)!
            pass = (alertController.textFields?[3].text)!
            self.login()
            
        }
        alertController.addAction(OKAction)
        
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    /////////////////////
    // LOGIN IN POP UP //
    /////////////////////
    
    func tryLogin(_ sender:UIButton){
        let alertController = UIAlertController(title: "Login", message: "", preferredStyle: .alert)
        
        // Email
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.text = username
            textField.keyboardType = .emailAddress
        }
        // Password
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Login", style: .default) { (action) in
            // NEED ERROR CHECK
            print("Login IN->>")
            username = (alertController.textFields?[0].text!)!
            pass = (alertController.textFields?[1].text)!
            self.login()
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    ///////////////////
    // CREATE TABLES //
    ///////////////////
    
    func createTables(){
        try! db.run(health.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true);
            t.column(uId)
            t.column(date)
            t.column(uWeight)
            t.column(heartRate)
            t.column(steps)
        })
        try! db.run(users.create(ifNotExists: true) { t in
            t.column(email, primaryKey: true)
            t.column(fName)
            t.column(lName)
            t.column(height)
            t.column(weight)
            t.column(age)
            t.column(sex)
            t.column(password)
            
            
        })
    }
    
    ////////////////////////
    // ADD NEW USER TO DB //
    ////////////////////////
    
    func addNewUserDB(_first:String,_last:String,_email:String,_height:Int64,_weight:Int64,_password:String,_age:Int64,_sex:String){
        print("PATH!")
        print(path)
        print("END PATH")
        let insert = users.insert(email <- _email,fName <- _first,lName <- _last, password <- _password.md5(), height <- _height, weight <- _weight, age <- _age, sex <- _sex)
        try! db.run(insert)
        registerLocal()
        
    }
    
    ///////////////
    //   LOGIN   //
    ///////////////
    
    func login(){
        for user in try! db.prepare(users) {
            if (user[email] == username && user[password] == pass.md5()) {
                let backItem = UIBarButtonItem()
                backItem.title = "Log Out"
                navigationItem.backBarButtonItem = backItem
                navigationController?.navigationBar.barTintColor = _accentColor
                navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: _fontColor]
                let destination = SecondVC() // Your destination
                self.navigationController?.pushViewController(destination, animated: true)
                avgWeight()
                let hr = avgHeartRate()
                print ("HR:")
                print (hr)
                avgHRData = Int(hr)
                let step = avgSteps()
                print ("Steps:")
                print (step)
                avgStepData = Int(step)
                
                
            } else {
                print("ERROR LOGING")
            }
        }
    }
    
    func autoLogin(){
        for user in try! db.prepare(users) {
            if (user[email] == username && user[password] == pass) {
                let backItem = UIBarButtonItem()
                backItem.title = "Log Out"
                navigationController?.navigationBar.barTintColor = _accentColor
                navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: _fontColor]
                navigationItem.backBarButtonItem = backItem
                let destination = SecondVC() // Your destination
                self.navigationController?.pushViewController(destination, animated: true)
                avgWeight()
                let hr = avgHeartRate()
                print ("HR:")
                print (hr)
                avgHRData = Int(hr)
                let step = avgSteps()
                print ("Steps:")
                print (step)
                avgStepData = Int(step)
                
            } else {
                print("ERROR LOGING")
            }
        }
        
    }
}

/////////////////////
// CREATE AVERAGES //
/////////////////////

// Average Weight
func avgWeight() -> Decimal{
    var bmi = Decimal(0)
    
    
    for user in try! db.prepare(users) {
        if (user[email] == username) {
            let w = Decimal(user[weight])
            let h = pow(Decimal(user[height]),2)
            bmi = (w/h * (703))
        }
    }
    
    print("BMI:")
    print(bmi)
    
    if( bmi < 18.5){
        print("Underweight")
    }
    else if(bmi >= 18.5 && bmi <= 24.9){
        print("Healthy Weight")
    }
    else if( bmi >= 25.0 && bmi <= 29.9){
        print("Overweight")
    }
    else{
        print ("Obese");
    }
    
    return bmi
    
}

func avgHeartRate() -> Int64 {
    var hr = 0
    for user in try! db.prepare(users) {
        if (user[email] == username) {
            let _age = user[age]
            if(_age <= 20 ){
                hr = 135
            }
            else if(_age >= 20 && _age < 30){
                hr = 128
            }
            else if(_age >= 30 && _age < 35){
                hr = 125
            }
            else if(_age >= 35 && _age < 40){
                hr = 121
            }
            else if(_age >= 40 && _age < 45){
                hr = 118
            }
            else if(_age >= 45 && _age < 50){
                hr = 115
            }
            else if(_age >= 50 && _age < 55){
                hr = 112
            }
            else if(_age >= 55 && _age < 60){
                hr = 110
            }
            else if(_age >= 60 && _age < 65){
                hr = 108
            }
            else if(_age >= 65 && _age < 70){
                hr = 106
            }
            else if(_age >= 70 ){
                hr = 103
            }
        }
    }
    return Int64(hr)
}

//Average Steps

func avgSteps() -> Int64 {
    var steps = 0
    for user in try! db.prepare(users) {
        if (user[email] == username) {
            let _age = user[age]
            if(_age <= 10 ){
                steps = 14000
            }
            else if(_age >= 10 && _age < 20 ){
                steps = 11500
            }
            else if(_age >= 20 && _age < 50 ){
                steps = 10000
            }
            else if ( _age > 50 ){
                steps = 7250
            }
        }
    }
    return Int64(steps)
}

func registerLocal() {
    let center = UNUserNotificationCenter.current()
    
    center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        if granted {
            scheduleLocal()
        } else {
            print("D'oh")
        }
    }
}

func scheduleLocal() {
    print ("DOES IT GET HERE????")
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = NSString.localizedUserNotificationString(forKey: "DID YOU ADD DATA TODAY?!", arguments: nil)
    content.body = NSString.localizedUserNotificationString(forKey: "STEPPY your way to success!", arguments: nil)
    content.sound = UNNotificationSound.default()
    // Set time to notify the user to 6:30 PM
    var dateComponents = DateComponents()
    dateComponents.hour = 18
    dateComponents.minute = 30
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    center.add(request)
    
}
