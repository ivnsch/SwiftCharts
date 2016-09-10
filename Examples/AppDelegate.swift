//
//  AppDelegate.swift
//  Examples
//
//  Created by ischuetz on 08/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            let splitViewController = self.window!.rootViewController as! UISplitViewController
            let navigationController = splitViewController.viewControllers.last as! UINavigationController
            splitViewController.delegate = self
            
            if #available(iOS 8.0, *) {
                navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            }
        }
        
        return true

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.detailItem == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    
    fileprivate func setSplitSwipeEnabled(_ enabled: Bool) {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let splitViewController = UIApplication.shared.delegate?.window!!.rootViewController as! UISplitViewController
            splitViewController.presentsWithGesture = enabled
        }
    }
    
    func splitViewController(_ svc: UISplitViewController, willHide aViewController: UIViewController, with barButtonItem: UIBarButtonItem, for pc: UIPopoverController) {
        
        let navigationController = svc.viewControllers[svc.viewControllers.count-1] as! UINavigationController
        if let topAsDetailController = navigationController.topViewController as? DetailViewController {
                barButtonItem.title = "Examples"
                topAsDetailController.navigationItem.setLeftBarButton(barButtonItem, animated: true)
        }
    }
}


// src: http://stackoverflow.com/a/27399688/930450
extension UISplitViewController {
    func toggleMasterView() {
        if #available(iOS 8.0, *) {
            let barButtonItem = self.displayModeButtonItem
            UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
        }
    }
}
