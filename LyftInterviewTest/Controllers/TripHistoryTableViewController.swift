//
//  TripHistoryTableViewController.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/23/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import UIKit

class TripHistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var fetchedResultsController = Trip.MR_fetchAllSortedBy("startTime",
        ascending: false,
        withPredicate: nil,
        groupBy: nil,
        delegate: nil)

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
            return fetchedObjects.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tripCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
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
                tableView.insertRowsAtIndexPaths([newPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let idxPath = indexPath {
                tableView.deleteRowsAtIndexPaths([idxPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let idxPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(idxPath) {
                    configureCell(cell, atIndexPath: idxPath)
                }
            }
        case .Move:
            if let newPath = newIndexPath {
                if let idxPath = indexPath {
                    tableView.deleteRowsAtIndexPaths([idxPath], withRowAnimation: .Fade)
                    tableView.insertRowsAtIndexPaths([newPath], withRowAnimation: .Fade)
                }
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    // MARK: - Internal
    
    private func configureCell(cell: UITableViewCell, atIndexPath: NSIndexPath) {
        
    }
    
    
    
    
}