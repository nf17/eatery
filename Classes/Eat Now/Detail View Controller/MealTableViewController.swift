//
//  MealTableViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

protocol MealScrollDelegate {
    func mealScrollViewDidBeginPushing(scrollView: UIScrollView)
    func mealScrollViewDidPushOffset(scrollView: UIScrollView, offset: CGPoint) -> CGFloat
    func mealScrollViewDidEndPushing(scrollView: UIScrollView)
    var outerScrollOffset: CGPoint { get }
    func resetOuterScrollView()
}

class MealTableViewController: UITableViewController {
    
    var eatery: Eatery!
    var meal: String!
    var event: Event?
    
    private var tracking = false
    private var previousScrollOffset: CGFloat = 0
    var active = true
    
    var scrollDelegate: MealScrollDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Appearance
        view.backgroundColor = .greenColor()
        
        // TableView Config
        tableView.backgroundColor = .clearColor()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerNib(UINib(nibName: "MealTableViewCell", bundle: nil), forCellReuseIdentifier: "MealCell")
        
        tableView.separatorStyle = .None
        
        tableView.scrollEnabled = false
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let e = event {
            return e.menu.count == 0 ? 1 : e.menu.count
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MealCell", forIndexPath: indexPath) as! MealTableViewCell
        
        var menu = event?.menu
        
        if let hardcoded = eatery.hardcodedMenu {
            menu = hardcoded
        }
        
        if let menu = menu {
            let stationArray: [String] = Array(menu.keys)
            
            var title = "--"
            var content: NSMutableAttributedString = NSMutableAttributedString(string: "No menu available")
            
            if stationArray.count != 0 {
                title = stationArray[indexPath.row]
                let allItems = menu[title]
                let names: [NSMutableAttributedString] = allItems!.map { $0.healthy ? NSMutableAttributedString(string: "\($0.name.trim()) ").appendImage(UIImage(named: "appleIcon")!, yOffset: -1.5) : NSMutableAttributedString(string: $0.name)
                }
                
                content = names.isEmpty ? NSMutableAttributedString(string: "No items to show") : NSMutableAttributedString(string: "\n").join(names)
            }
            
            if title == "General" {
                title = "Menu"
            }
            
            cell.titleLabel.text = title.uppercaseString
            cell.contentLabel.attributedText = content
            cell.selectionStyle = .None
        } else {
            cell.titleLabel.text = "No menu available"
            cell.contentLabel.attributedText = NSAttributedString(string: "")
        }

        return cell
    }
}