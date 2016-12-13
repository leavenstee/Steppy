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
    
    // TODO
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = _backgroundColor
        // Labels and Buttons
        loadDBToLocals()
        /// NEEED SDESIGN
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let ageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let genderLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let bmiStatusLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let stepTotalLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let userGuideBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        
        nameLabel.center = CGPoint(x: 160, y: 100)
        ageLbl.center = CGPoint(x: 160, y: 150)
        genderLbl.center = CGPoint(x: 160, y: 200)
        bmiStatusLbl.center = CGPoint(x: 160, y: 250)
        stepTotalLbl.center = CGPoint(x: 160, y: 300)
        userGuideBtn.center = CGPoint(x: view.frame.width/2-100, y: view.frame.height-50)
        
        // Set Label Title
        nameLabel.text = uName
        ageLbl.text = uAge
        genderLbl.text = uSex
        bmiStatusLbl.text = uBMI
        stepTotalLbl.text = stepTotal
        userGuideBtn.setTitle("User Guide", for: .normal)
        userGuideBtn.setTitleColor(_fontColor, for: .normal)    
        
        nameLabel.textColor = _fontColor
        genderLbl.textColor = _fontColor
        bmiStatusLbl.textColor = _fontColor
        ageLbl.textColor = _fontColor
        stepTotalLbl.textColor = _fontColor
        
        
        // Set button target
        userGuideBtn.addTarget(self, action: #selector(loadUserGuide(sender:)), for: .touchUpInside)
        // add to view
        view.addSubview(nameLabel)
        view.addSubview(ageLbl)
        view.addSubview(genderLbl)
        view.addSubview(bmiStatusLbl)
        view.addSubview(stepTotalLbl)
        view.addSubview(userGuideBtn)
        
        
        
        
    }
    
    func loadUserGuide(sender:UIButton){
        print ("GOT IT")
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        let url = NSURL (string: "http://leavenstee.me/images/SteppyUserManual.pdf");
        let requestObj = NSURLRequest(url: url! as URL);
        webView.loadRequest(requestObj as URLRequest);
        view.addSubview(webView)
    }
    
    func loadDBToLocals() {
        var stepTotalCount : Int64
        stepTotalCount = 0
        for user in try! db.prepare(users) {
            if (user[email] == username) {
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
        
        for t in try! db.prepare(health) {
            if (t[uId] == username) {
                stepTotalCount = stepTotalCount + t[steps]
            }
        }
        stepTotal = "Total Steps: \(stepTotalCount)"
    }
    
}
