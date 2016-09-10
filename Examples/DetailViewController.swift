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
    
    lazy var chartFrame: CGRect! = {
        CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: self.view.frame.size.height - 80)
    }()
    
    var detailItem: Example? {
        didSet {
            self.configureView()
        }
    }
    var currentExampleController: UIViewController?
    
    func configureView() {
        
        if let example: Example = self.detailItem  {
            switch example {
            case .helloWorld:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(HelloWorld())
            case .bars:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BarsExample())
            case .stackedBars:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(StackedBarsExample())
            case .barsPlusMinus:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BarsPlusMinusWithGradientExample())
            case .groupedBars:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(GroupedBarsExample())
            case .barsStackedGrouped:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(GroupedAndStackedBarsExample())
            case .scatter:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(ScatterExample())
            case .notifications:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(NotificationsExample())
            case .target:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(TargetExample())
            case .areas:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(AreasExample())
            case .bubble:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BubbleExample())
            case .combination:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BarsPlusMinusAndLinesExample())
            case .scroll:
                self.setSplitSwipeEnabled(false)
                self.automaticallyAdjustsScrollViewInsets = false
                self.showExampleController(ScrollExample())
            case .coords:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CoordsExample())
            case .tracker:
                self.setSplitSwipeEnabled(false)
                self.showExampleController(TrackerExample())
            case .multiTracker:
                self.setSplitSwipeEnabled(false)
                self.showExampleController(MultiTrackerExample())
            case .equalSpacing:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(EqualSpacingExample())
            case .customUnits:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CustomUnitsExample())
            case .multival:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(MultipleLabelsExample())
            case .multiAxis:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(MultipleAxesExample())
            case .multiAxisInteractive:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(MultipleAxesInteractiveExample())
            case .candleStick:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CandleStickExample())
            case .cubiclines:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CubicLinesExample())
            case .notNumeric:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(NotNumericExample())
            case .candleStickInteractive:
                self.setSplitSwipeEnabled(false)
                self.showExampleController(CandleStickInteractiveExample())
            case .trendline:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(TrendlineExample())
            }
        }
    }
    
    fileprivate func showExampleController(_ controller: UIViewController) {
        if let currentExampleController = self.currentExampleController {
            currentExampleController.removeFromParentViewController()
            currentExampleController.view.removeFromSuperview()
        }
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
        self.currentExampleController = controller
    }
    
    fileprivate func setSplitSwipeEnabled(_ enabled: Bool) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let splitViewController = UIApplication.shared.delegate?.window!!.rootViewController as! UISplitViewController
            splitViewController.presentsWithGesture = enabled
        }
    }
}

