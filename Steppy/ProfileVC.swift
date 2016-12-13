//
//  UserInfoVC.swift
//  steppy2.0
//
//  Created by Steven Lee on 11/17/16.
//  Copyright © 2016 Steven Lee. All rights reserved.
//


import UIKit
import SQLite
import HealthKit

class ProfileVC: UIViewController {
    // Locals Info
    var uName = ""
    var uAge = ""
    var uSex = ""
    var uBMI = ""
    var stepTotal = ""
    var aroundTheWorld = ""
    var toTheMoon = ""
    var avgGoal = ""
    
    ///////////////////
    // VIEW DID LOAD //
    ///////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = _backgroundColor
        // Calls Load DB
        loadDBToLocals()
        // Creates Labels and Buttons
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let ageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let genderLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let bmiStatusLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let stepTotalLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let worldLBl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let userGuideBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
        let goalLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 600, height: 21));
        // Place Labels
        nameLabel.center = CGPoint(x: 160, y: 100)
        ageLbl.center = CGPoint(x: 160, y: 150)
        genderLbl.center = CGPoint(x: 160, y: 200)
        bmiStatusLbl.center = CGPoint(x: 160, y: 250)
        stepTotalLbl.center = CGPoint(x: 160, y: 300)
        worldLBl.center = CGPoint(x: 160, y: 350)
        goalLbl.center = CGPoint(x: 300+60, y: 400)
        userGuideBtn.center = CGPoint(x: view.frame.width/2-100, y: view.frame.height-50)
        // Set Label Title
        nameLabel.text = uName
        ageLbl.text = uAge
        genderLbl.text = uSex
        bmiStatusLbl.text = uBMI
        stepTotalLbl.text = stepTotal
        goalLbl.text = avgGoal
        worldLBl.text = aroundTheWorld
        userGuideBtn.setTitle("User Guide", for: .normal)
        // Set Label and button colors
        userGuideBtn.setTitleColor(_fontColor, for: .normal)
        nameLabel.textColor = _fontColor
        genderLbl.textColor = _fontColor
        bmiStatusLbl.textColor = _fontColor
        ageLbl.textColor = _fontColor
        worldLBl.textColor = _fontColor
        stepTotalLbl.textColor = _fontColor
        goalLbl.textColor = _fontColor
        // Set button target
        userGuideBtn.addTarget(self, action: #selector(loadUserGuide(sender:)), for: .touchUpInside)
        // add to view
        view.addSubview(nameLabel)
        view.addSubview(ageLbl)
        view.addSubview(genderLbl)
        view.addSubview(bmiStatusLbl)
        view.addSubview(stepTotalLbl)
        view.addSubview(userGuideBtn)
        view.addSubview(worldLBl)
        view.addSubview(goalLbl)
    }
    
    /////////////////////
    // LOAD USER GUIDE //
    /////////////////////
    func loadUserGuide(sender:UIButton){
        // Creates Webview and adds it to the superview
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        let url = NSURL (string: "http://leavenstee.me/images/SteppyUserManual.pdf");
        let requestObj = NSURLRequest(url: url! as URL);
        webView.loadRequest(requestObj as URLRequest);
        view.addSubview(webView)
    }
    
    //////////////////////////////
    // LOAD DATABSE TO THE PAGE //
    //////////////////////////////
    func loadDBToLocals() {
        var stepTotalCount : Int64
        stepTotalCount = 0
        var goalCount : Int64
        goalCount = 0
        // User Databse Parse
        for user in try! db.prepare(users) {
            // Checks for correct username
            if (user[email] == username) {
                // Sets Globals to correct goals
                uName = "\(user[fName]) \(user[lName]!)"
                uAge = "\(user[age])"
                uBMI = "\(user[weight])"
                if(user[sex] == "m"){
                    uSex = "Male"
                } else {
                    uSex = "Female"
                }
            }
        }
        // Health Database Parse
        for t in try! db.prepare(health) {
            // Checks for correct username
            if (t[uId] == username) {
                // Increase Step Count
                stepTotalCount = stepTotalCount + t[steps]
                goalCount = goalCount + 10000
            }
        }
        stepTotal = "Total Steps: \(stepTotalCount)"
        aroundTheWorld = "\((stepTotalCount/65740092)*100)% around the earth!"
        if(stepTotalCount < goalCount){
            avgGoal = "You are \(goalCount - stepTotalCount) steps behind!"
        } else {
            avgGoal = "You are \(stepTotalCount - goalCount) steps above!"
        }
    }
    
}
