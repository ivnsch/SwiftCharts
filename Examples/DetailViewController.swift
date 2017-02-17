//
//  DetailViewController.swift
//  SwiftCharts
//
//  Created by ischuetz on 20/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    lazy private(set) var chartFrame: CGRect! = {
        CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: self.view.frame.size.height - 80)
    }()
    
    var detailItem: Example? {
        didSet {
            configureView()
        }
    }
    var currentExampleController: UIViewController?
    
    func configureView() {
        
        if let example: Example = detailItem  {
            switch example {
            case .helloWorld:
                setSplitSwipeEnabled(true)
                showExampleController(HelloWorld())
            case .bars:
                setSplitSwipeEnabled(true)
                showExampleController(BarsExample())
            case .stackedBars:
                setSplitSwipeEnabled(true)
                showExampleController(StackedBarsExample())
            case .barsPlusMinus:
                setSplitSwipeEnabled(true)
                showExampleController(BarsPlusMinusWithGradientExample())
            case .groupedBars:
                setSplitSwipeEnabled(true)
                showExampleController(GroupedBarsExample())
            case .barsStackedGrouped:
                setSplitSwipeEnabled(true)
                showExampleController(GroupedAndStackedBarsExample())
            case .scatter:
                setSplitSwipeEnabled(true)
                showExampleController(ScatterExample())
            case .notifications:
                setSplitSwipeEnabled(true)
                showExampleController(NotificationsExample())
            case .target:
                setSplitSwipeEnabled(true)
                showExampleController(TargetExample())
            case .areas:
                setSplitSwipeEnabled(true)
                showExampleController(AreasExample())
            case .rangedAxis:
                setSplitSwipeEnabled(true)
                showExampleController(RangedAxisExample())
            case .bubble:
                setSplitSwipeEnabled(true)
                showExampleController(BubbleExample())
            case .combination:
                setSplitSwipeEnabled(true)
                showExampleController(BarsPlusMinusAndLinesExample())
            case .coords:
                setSplitSwipeEnabled(true)
                showExampleController(CoordsExample())
            case .tracker:
                setSplitSwipeEnabled(false)
                showExampleController(TrackerExample())
            case .multiTracker:
                setSplitSwipeEnabled(false)
                showExampleController(MultiTrackerExample())
            case .equalSpacing:
                setSplitSwipeEnabled(true)
                showExampleController(EqualSpacingExample())
            case .customUnits:
                setSplitSwipeEnabled(true)
                showExampleController(CustomUnitsExample())
            case .multival:
                setSplitSwipeEnabled(true)
                showExampleController(MultipleLabelsExample())
            case .multiAxis:
                setSplitSwipeEnabled(true)
                showExampleController(MultipleAxesExample())
            case .multiAxisInteractive:
                setSplitSwipeEnabled(true)
                showExampleController(MultipleAxesInteractiveExample())
            case .candleStick:
                setSplitSwipeEnabled(true)
                showExampleController(CandleStickExample())
            case .cubiclines:
                setSplitSwipeEnabled(true)
                showExampleController(CubicLinesExample())
            case .notNumeric:
                setSplitSwipeEnabled(true)
                showExampleController(NotNumericExample())
            case .candleStickInteractive:
                setSplitSwipeEnabled(false)
                showExampleController(CandleStickInteractiveExample())
            case .trendline:
                setSplitSwipeEnabled(true)
                showExampleController(TrendlineExample())
            }
        }
    }
    
    fileprivate func showExampleController(_ controller: UIViewController) {
        if let currentExampleController = currentExampleController {
            currentExampleController.removeFromParentViewController()
            currentExampleController.view.removeFromSuperview()
        }
        addChildViewController(controller)
        view.addSubview(controller.view)
        currentExampleController = controller
    }
    
    fileprivate func setSplitSwipeEnabled(_ enabled: Bool) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let splitViewController = UIApplication.shared.delegate?.window!!.rootViewController as! UISplitViewController
            splitViewController.presentsWithGesture = enabled
        }
    }
}

