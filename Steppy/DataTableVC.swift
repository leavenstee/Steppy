
import UIKit
import SQLite

class DataTableVC: UIViewController,UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    var healthTable = UITableView()
    let cellReuseIdentifier = "cell"
    var items: [String] = []
    var ids: [Int64] = []
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(username)'s info"
        readDB()
        healthTable.frame         =   CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        healthTable.delegate      =   self
        healthTable.dataSource    =   self
        healthTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            healthTable.tableHeaderView = controller.searchBar
            return controller
        })()
        self.view.addSubview(healthTable)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return self.filteredTableData.count
        }
        else {
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        if (self.resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
            
            return cell
        }
        else {
            cell.textLabel?.text = self.items[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var editDate = ""
        var editHR = ""
        var editWe = ""
        var editSt = ""
        for h in try! db.prepare(health) {
            if (h[uId] == username) {
                if(h[id] == ids[indexPath.row]){
                    editDate = h[date]
                    editHR = String(h[heartRate])
                    editSt = String(h[steps])
                    editWe = String(h[uWeight])
                    
                }
            }
        }
        let alertController = UIAlertController(title: "Edit Data", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Date (yyyy-MM-dd)"
            textField.text = editDate
            
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Heart Rate"
            textField.text = editHR
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Weight"
            textField.text = editWe
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Steps"
            textField.text = editSt
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            // Change Data let dateFormatter = DateFormatter()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let dateDED = dateFormatter.date(from: (alertController.textFields?[0].text!)!)
            
            if (dateDED?.compare(NSDate() as Date) != ComparisonResult.orderedDescending) {
                self.updateRow(path: indexPath.row, colect: alertController.textFields!)
                self.view.makeToast("Data Edited!", duration: 3.0, position: .top)
            } else {
                self.view.makeToast("That has not happened yet!", duration: 3.0, position: .top)
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (items as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        healthTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let alice = health.filter(id == ids[indexPath.row])
            try! db.run(alice.delete())
            self.view.makeToast("Deleted!", duration: 3.0, position: .top)
        }
        ids.removeAll()
        items.removeAll()
        readDB()
        healthTable.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func readDB(){
        for h in try! db.prepare(health) {
            if (h[uId] == username) {
                let dString = h[date]
                let hrString = String(h[heartRate])
                let sString = String(h[steps])
                let wString = String(h[uWeight])
                let temp = dString + " | " + hrString + " | " + sString + " | " + wString
                ids.append(h[id])
                items.append(temp)
            }
        }
        
    }

    func updateRow(path: Int, colect:[UITextField]) {
        let alice = health.filter(id == ids[path])
        try! db.run(alice.update(date <- colect[0].text!))
        try! db.run(alice.update(heartRate <- Int64(colect[1].text!)!))
        try! db.run(alice.update(uWeight <- Double(colect[2].text!)!))
        try! db.run(alice.update(steps <- Int64(colect[3].text!)!))
        ids.removeAll()
        items.removeAll()
        readDB()
        healthTable.reloadData()
    }
}
