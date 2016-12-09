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

class UserInfoVC: ViewController{
    // Locals Info
    
    
    // TODO
    override func viewDidLoad() {
        view.backgroundColor = _backgroundColor
        // Labels and Buttons
        loadDBToLocals()
        
        //        var nameLabel = UILabel(frame: CGRect(x: view.frame.width/2, y: view.frame.height/8, width: 100, height: 50))
        //        var ageLbl = UILabel(frame: CGRect(x: <#T##Double#>, y: <#T##Double#>, width: <#T##Double#>, height: <#T##Double#>))
        //        var genderLbl = UILabel(frame: CGRect(x: <#T##Double#>, y: <#T##Double#>, width: <#T##Double#>, height: <#T##Double#>))
        //        var bmiStatusLbl = UILabel(frame: CGRect(x: <#T##Double#>, y: <#T##Double#>, width: <#T##Double#>, height: <#T##Double#>))
        //       var moreInfoBtn = UIButton(frame:CGRect(x: <#T##Double#>, y: <#T##Double#>, width: <#T##Double#>, height: <#T##Double#>))
        //
        // Set Label Title
        //        nameLabel.text =
        //
        // add to view
        
        
        
    }
    
    func loadDBToLocals() {
        for user in try! db.prepare(users) {
            if (user[email] != username) {
            }
        }
    }
    
}
