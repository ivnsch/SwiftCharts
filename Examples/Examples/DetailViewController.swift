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
        CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 80)
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
            case .HelloWorld:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(HelloWorld())
            case .Bars:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BarsExample())
            case .StackedBars:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(StackedBarsExample())
            case .BarsPlusMinus:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BarsPlusMinusWithGradientExample())
            case .GroupedBars:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(GroupedBarsExample())
            case .BarsStackedGrouped:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(GroupedAndStackedBarsExample())
            case .Scatter:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(ScatterExample())
            case .Notifications:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(NotificationsExample())
            case .Target:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(TargetExample())
            case .Areas:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(AreasExample())
            case .Bubble:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BubbleExample())
            case .Combination:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(BarsPlusMinusAndLinesExample())
            case .Scroll:
                self.setSplitSwipeEnabled(false)
                self.automaticallyAdjustsScrollViewInsets = false
                self.showExampleController(ScrollExample())
            case .Coords:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CoordsExample())
            case .Tracker:
                self.setSplitSwipeEnabled(false)
                self.showExampleController(TrackerExample())
            case .EqualSpacing:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(EqualSpacingExample())
            case .CustomUnits:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CustomUnitsExample())
            case .Multival:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(MultipleLabelsExample())
            case .MultiAxis:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(MultipleAxesExample())
            case .MultiAxisInteractive:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(MultipleAxesInteractiveExample())
            case .CandleStick:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CandleStickExample())
            case .Cubiclines:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(CubicLinesExample())
            case .NotNumeric:
                self.setSplitSwipeEnabled(true)
                self.showExampleController(NotNumericExample())
            case .CandleStickInteractive:
                self.setSplitSwipeEnabled(false)
                self.showExampleController(CandleStickInteractiveExample())
            }
        }
    }
    
    private func showExampleController(controller: UIViewController) {
        if let currentExampleController = self.currentExampleController {
            currentExampleController.removeFromParentViewController()
            currentExampleController.view.removeFromSuperview()
        }
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
        self.currentExampleController = controller
    }
    
    private func setSplitSwipeEnabled(enabled: Bool) {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            let splitViewController = UIApplication.sharedApplication().delegate?.window!!.rootViewController as! UISplitViewController
            splitViewController.presentsWithGesture = enabled
        }
    }
}

