//
//  TripHistoryTableViewController.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/23/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import UIKit

private let offset = 1

class TripHistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var fetchedResultsController = Trip.MR_fetchAllSortedBy("startTime",
        ascending: false,
        withPredicate: NSPredicate(format: "end != nil"),
        groupBy: nil,
        delegate: nil)
    
    private var tripSwitch: UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            return fetchedObjects.count + offset
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as UITableViewCell
            
            if let theSwitch = cell.viewWithTag(1) as? UISwitch {
                if theSwitch != tripSwitch {
                    theSwitch.addTarget(self, action: "tripSwitchChanged", forControlEvents: .ValueChanged)
                }
                theSwitch.on = TripManager.sharedManager.loggingEnabled
                tripSwitch = theSwitch
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("tripCell", forIndexPath: indexPath) as UITableViewCell
            
            configureCell(cell, atIndexPath: offsetIndexPath(indexPath))
            
            return cell
        }
    }
    
    // MARK: Fetched results controller delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if type == .Insert {
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        } else if type == .Delete {
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let newPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([offsetIndexPath(newPath)], withRowAnimation: .Fade)
            }
        case .Delete:
            if let idxPath = indexPath {
                tableView.deleteRowsAtIndexPaths([offsetIndexPath(idxPath)], withRowAnimation: .Fade)
            }
        case .Update:
            if let idxPath = indexPath {
                let offsetPath = offsetIndexPath(idxPath)
                if let cell = tableView.cellForRowAtIndexPath(offsetPath) {
                    configureCell(cell, atIndexPath: offsetPath)
                }
            }
        case .Move:
            if let newPath = newIndexPath {
                if let idxPath = indexPath {
                    tableView.deleteRowsAtIndexPaths([offsetIndexPath(idxPath)], withRowAnimation: .Fade)
                    tableView.insertRowsAtIndexPaths([offsetIndexPath(newPath)], withRowAnimation: .Fade)
                }
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    // MARK: - Internal
    
    private func offsetIndexPath(originalPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: originalPath.row + offset, inSection: originalPath.section)
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath: NSIndexPath) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            if let trip = fetchedObjects[atIndexPath.row] as? Trip {
                cell.imageView?.contentMode = .Center
                if let label = cell.textLabel {
                    label.text = trip.displayString
                }
                if let sublabel = cell.detailTextLabel {
                    sublabel.text = trip.durationDisplayString
                }
            }
        }
    }
    
    func tripSwitchChanged() {
        println("Trip switch changed")
        if let theTripSwitch = tripSwitch {
            if theTripSwitch.on {
                println("Trip switch turned on")
                TripManager.sharedManager.enableLogging()
            } else {
                println("Trip switch turned off")
                TripManager.sharedManager.disableLogging()
            }
        }
    }
    
    
}
