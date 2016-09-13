//
//  MasterViewController.swift
//  SwiftCharts
//
//  Created by ischuetz on 20/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


enum Example {
    case helloWorld, bars, stackedBars, barsPlusMinus, groupedBars, barsStackedGrouped, scatter, areas, bubble, coords, target, multival, notifications, combination, scroll, equalSpacing, tracker, multiTracker, multiAxis, multiAxisInteractive, candleStick, cubiclines, notNumeric, candleStickInteractive, customUnits, trendline
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
        (.bubble, "Bubble, gradient bar mapping"),
        (.notNumeric, "Not numeric values"),
        (.scroll, "Multiline, Scroll"),
        (.coords, "Show touch coords (interactive)"),
        (.tracker, "Track touch (interactive)"),
        (.multiTracker, "Multi-chart touch tracking"),
        (.equalSpacing, "Fixed axis spacing"),
        (.customUnits, "Custom units, rotated labels"),
        (.multival, "Multiple axis labels"),
        (.multiAxis, "Multiple axes"),
        (.multiAxisInteractive, "Multiple axes (interactive)"),
        (.candleStick, "Candlestick"),
        (.candleStickInteractive, "Candlestick (interactive)"),
        (.cubiclines, "Cubic lines"),
        (.trendline, "Trendline")
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = ["NSFontAttributeName" : ExamplesDefaults.fontWithSize(22)]
        UIBarButtonItem.appearance().setTitleTextAttributes(["NSFontAttributeName" : ExamplesDefaults.fontWithSize(22)], for: UIControlState())
        
        if let split = self.splitViewController {
            
            let controllers = split.viewControllers
            
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
            let example = self.examples[1]
            self.detailViewController?.detailItem = example.0
            self.detailViewController?.title = example.1
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            func showExample(_ index: Int) {
                let example = self.examples[index]
                let controller = segue.destination as! DetailViewController
                controller.detailItem = example.0
                controller.title = example.1
                
            }
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                showExample(indexPath.row)
            } else {
                showExample(0)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let example = self.examples[indexPath.row]
            self.detailViewController?.detailItem = example.0
            self.detailViewController?.title = example.1
            
            self.splitViewController?.toggleMasterView()
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

