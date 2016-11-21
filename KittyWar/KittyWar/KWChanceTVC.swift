//
//  KWChanceTVC.swift
//  KittyWar
//
//  Created by Janet Zhang on 11/20/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit

class KWChanceTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add background img
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        
        // Do any additional setup after loading the view.
    }
    
    
    var chance = ["Double Purring", "Guaranteed Purring", "Purr and Draw", "Reverse Scratch", "Guard and Heal",
                  "Guard and Draw", "Can't Reverse", "Can't Guard", "Double Scratch"]
    
    // MARK: -Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chance.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChanceCell", for: indexPath)
        
        //cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        //cell.textLabel?.text = content[indexPath.row]
        
        let chanceName = chance[indexPath.row]
        cell.textLabel?.text = chanceName
        //cell.detailTextLabel?.text = "Choose me! Meow~"
        cell.imageView?.image = UIImage(named: chanceName)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Chance Card Gallery"
    }

  
}
