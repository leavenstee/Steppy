//
//  ChartVC.swift
//  steppy2.0
//
//  Created by Steven Lee on 10/13/16.
//  Copyright © 2016 Steven Lee. All rights reserved.
//

import UIKit
import SwiftCharts
import SQLite

class ChartVC: UIViewController {
    
    fileprivate var chart: Chart? // arc
    var points = [(0.0,0.0)]
    //    var avgpoints = [(0.0,0.0)]
    var goal = [(0.0,0.0)]
    var maxData = 0
    var totalCnt = 0
    var byNum = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = _backgroundColor
        setPoints()
        
        if(maxData == 0){
            maxData = 10
            totalCnt = 2;
        }
        let chartConfig = ChartConfigXY(
            chartSettings: ExamplesDefaults.chartSettings,
            xAxisConfig: ChartAxisConfig(from: 1, to: Double(totalCnt-1), by: 1),
            yAxisConfig: ChartAxisConfig(from: 0, to: Double(maxData), by: Double(byNum)),
            xAxisLabelSettings: ExamplesDefaults.labelSettings,
            yAxisLabelSettings: ExamplesDefaults.labelSettings.defaultVertical()
        )
        
        let chart = LineChart(
            frame: ExamplesDefaults.chartFrame(self.view.bounds),
            chartConfig: chartConfig,
            xTitle: "Past \(totalCnt-1) Days",
            yTitle: "Data",
            lines: [
                (chartPoints: points, color: UIColor.red),(chartPoints: goal, color: UIColor.blue)
            ]
        )
        
        
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    func setPoints(){
        var count = 1.0
        var curDate = NSDate()
        points.removeAll()
        goal.removeAll()
        maxData = 0;
        
        if(chartType == 1){
            byNum = 1000
            for h in try! db.prepare(health) {
                if (h[uId] == username) {
                    if(Int(h[steps]) > maxData || Int(h[steps]) == nil){
                        maxData = Int(h[steps]+1000)
                    }
                    
                    points.append((count,Double(h[steps])))
                    goal.append((count,Double(avgStepData)))
                    
                    count += 1;
                }
            }
        } else if (chartType == 2){
            byNum = 10
            for h in try! db.prepare(health) {
                if (h[uId] == username) {
                    if(Int(h[uWeight]) > maxData || Int(h[uWeight]) == nil){
                        maxData = Int(h[uWeight]+10)
                    }
                    points.append((count,Double(h[uWeight])))
                    count += 1;
                    
                }
            }
        } else if (chartType == 3){
            byNum = 5
            for h in try! db.prepare(health) {
                if (h[uId] == username) {
                    if(Int(h[heartRate]) > maxData || Int(h[heartRate]) == nil){
                        maxData = Int(h[heartRate]+10)
                    }
                    
                    points.append((count,Double(h[heartRate])))
                    goal.append((count,Double(avgHRData)))
                    count += 1;
                }
            }
        }
        totalCnt = Int(count);
        
    }
    
}
