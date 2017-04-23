//
//  MasterViewController.swift
//  SwiftCharts
//
//  Created by ischuetz on 20/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


enum Example {
    case helloWorld, bars, stackedBars, barsPlusMinus, groupedBars, barsStackedGrouped, scatter, areas, rangedAxis, bubble, coords, target, multival, notifications, combination, equalSpacing, tracker, multiTracker, multiAxis, multiAxisInteractive, candleStick, cubiclines, notNumeric, candleStickInteractive, customUnits, trendline
}

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var examples: [(Example, String)] = [
        (.helloWorld, "Hello World"),
        (.bars, "Bars"),
        (.stackedBars, "Stacked bars"),
        (.barsPlusMinus, "+/- bars with dynamic gradient"),
        (.groupedBars, "Grouped bars"),
        (.barsStackedGrouped, "Stacked, grouped bars"),
        (.combination, "+/- bars and line"),
        (.scatter, "Scatter"),
        (.notifications, "Notifications (interactive)"),
        (.target, "Target point animation"),
        (.areas, "Areas, lines, circles (interactive)"),
        (.rangedAxis, "Ranged axis, rotation"),
        (.bubble, "Bubble, gradient bar mapping"),
        (.notNumeric, "Not numeric values"),
        (.coords, "Show touch coords (interactive)"),
        (.tracker, "Track touch (interactive)"),
        (.multiTracker, "Multi-chart touch tracking"),
        (.equalSpacing, "Fixed axis spacing"),
        (.customUnits, "Custom units, scrollable"),
        (.multival, "Multiple axis labels"),
        (.multiAxis, "Multiple axes"),
        (.multiAxisInteractive, "Multiple axes (interactive)"),
        (.candleStick, "Candlestick"),
        (.candleStickInteractive, "Candlestick (tracker, custom views)"),
        (.cubiclines, "Cubic lines"),
        (.trendline, "Trendline")
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            clearsSelectionOnViewWillAppear = false
            preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = ["NSFontAttributeName" : ExamplesDefaults.fontWithSize(22)]
        UIBarButtonItem.appearance().setTitleTextAttributes(["NSFontAttributeName" : ExamplesDefaults.fontWithSize(22)], for: UIControlState())
        
        if let split = splitViewController {
            
            let controllers = split.viewControllers
            
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
            let example = examples[1]
            detailViewController?.detailItem = example.0
            detailViewController?.title = example.1
        }
        
        
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            func showExample(_ index: Int) {
                let example = examples[index]
                let controller = segue.destination as! DetailViewController
                controller.detailItem = example.0
                controller.title = example.1
                
            }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                showExample((indexPath as NSIndexPath).row)
            } else {
                showExample(11)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let example = examples[indexPath.row]
            detailViewController?.detailItem = example.0
            detailViewController?.title = example.1
            
            splitViewController?.toggleMasterView()
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.textLabel!.text = examples[indexPath.row].1
        cell.textLabel!.font = ExamplesDefaults.fontWithSize(Env.iPad ? 22 : 16)
        return cell
    }
}

