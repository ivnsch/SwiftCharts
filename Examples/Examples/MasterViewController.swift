//
//  MasterViewController.swift
//  SwiftCharts
//
//  Created by ischuetz on 20/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


enum Example {
    case HelloWorld, Bars, StackedBars, BarsPlusMinus, GroupedBars, BarsStackedGrouped, Scatter, Areas, Bubble, Coords, Target, Multival, Notifications, Combination, Scroll, EqualSpacing, Tracker, MultiAxis, MultiAxisInteractive, CandleStick, Cubiclines, NotNumeric, CandleStickInteractive, CustomUnits
}

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var examples: [(Example, String)] = [
        (.HelloWorld, "Hello World"),
        (.Bars, "Bars"),
        (.StackedBars, "Stacked bars"),
        (.BarsPlusMinus, "+/- bars with dynamic gradient"),
        (.GroupedBars, "Grouped bars"),
        (.BarsStackedGrouped, "Stacked, grouped bars"),
        (.Combination, "+/- bars and line"),
        (.Scatter, "Scatter"),
        (.Notifications, "Notifications (interactive)"),
        (.Target, "Target point animation"),
        (.Areas, "Areas, lines, circles (interactive)"),
        (.Bubble, "Bubble, gradient bar mapping"),
        (.NotNumeric, "Not numeric values"),
        (.Scroll, "Multiline, Scroll"),
        (.Coords, "Show touch coords (interactive)"),
        (.Tracker, "Track touch (interactive)"),
        (.EqualSpacing, "Fixed axis spacing"),
        (.CustomUnits, "Custom units, rotated labels"),
        (.Multival, "Multiple axis labels"),
        (.MultiAxis, "Multiple axes"),
        (.MultiAxisInteractive, "Multiple axes (interactive)"),
        (.CandleStick, "Candlestick"),
        (.CandleStickInteractive, "Candlestick (interactive)"),
        (.Cubiclines, "Cubic lines")
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes = ["NSFontAttributeName" : ExamplesDefaults.fontWithSize(22)]
        UIBarButtonItem.appearance().setTitleTextAttributes(["NSFontAttributeName" : ExamplesDefaults.fontWithSize(22)], forState: UIControlState.Normal)
        
        if let split = self.splitViewController {
            
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
            
            let example = self.examples[1]
            self.detailViewController?.detailItem = example.0
            self.detailViewController?.title = example.1
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            func showExample(index: Int) {
                let example = self.examples[index]
                let controller = segue.destinationViewController as! DetailViewController
                controller.detailItem = example.0
                controller.title = example.1

            }
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                showExample(indexPath.row)
            } else {
                showExample(0)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            let example = self.examples[indexPath.row]
            self.detailViewController?.detailItem = example.0
            self.detailViewController?.title = example.1

            self.splitViewController?.toggleMasterView()
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = examples[indexPath.row].1
        cell.textLabel!.font = ExamplesDefaults.fontWithSize(Env.iPad ? 22 : 16)
        return cell
    }
}

