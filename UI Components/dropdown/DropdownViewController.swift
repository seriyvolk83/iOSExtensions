//
//  DropdownViewController.swift
//  dodo
//
//  Created by TCASSEMBLER on 13.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

/**
 * Item in dropdown list
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
class DropdownItem {
    
    /// the ID of the item
    let id: String
    
    /// the text to display
    let title: String
    
    /**
     Instantiate DropdownItem
     
     - parameter id:    the id
     - parameter title: the title
     
     - returns: new instance
     */
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

/**
 * DropdownViewController delegate protocol
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
protocol DropdownViewControllerDelegate {
    
    /**
     Notify about selected item
     
     - parameter modal:        the modal view controller
     - parameter selectedItem: the selected item
     */
    func dropdownItemSeleced(modal: DropdownViewController, selectedItem: DropdownItem)
    
    /**
     Notify about tapping outside of the dropdown list
     
     - parameter modal:        the modal view controller
     */
    func dropdownCanceled(modal: DropdownViewController)
}


/**
 * Dropdown list
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
final class DropdownViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// the selected item color
    let SELECTED_ITEM_COLOR = UIColor(r: 29, g: 37, b: 44)
    
    /// the cell height
    let CELL_HEIGHT: CGFloat = 44
    
    // the maximum height of the dropdown list
    var MAX_HEIGHT: CGFloat = 550
    
    // top and bottom extra margins for the table
    let EXTRA_VERTICAL_MARGINS: CGFloat = 7
    
    /// outlets
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var tableTopMargin: NSLayoutConstraint!
    @IBOutlet weak var tableWidth: NSLayoutConstraint!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    /// items to show
    var items = [DropdownItem]()
    
    /// the selected item
    var selectedItem: DropdownItem?
    
    /// the delegate reference
    var delegate: DropdownViewControllerDelegate?
    
    /// the rectangle to show the drop down list from
    var targetRectangle: CGRect!
    
    /**
     Show dropdown list
     
     - parameter items:                the items to show
     - parameter selectedItem:         the selected item
     - parameter delegate:             the delegate
     - parameter fromView:             the view to show from
     - parameter containerView:        the container view
     - parameter parentViewController: the parent view controller
     - parameter height:               the custom height for the dropdown list
     - parameter yOffset:              the custom y offset for the dropdown list
     */
    class func show(items: [DropdownItem], selectedItem: DropdownItem?, delegate: DropdownViewControllerDelegate,
                    fromView: UIView,
                    inView containerView: UIView,
                    parentViewController: UIViewController, height: CGFloat? = nil, yOffset: CGFloat = 0) {
        
        if let vc = parentViewController.create(DropdownViewController.self, storyboardName: "Dashboard") {
            vc.items = items
            vc.selectedItem = selectedItem
            vc.delegate = delegate
            vc.targetRectangle = fromView.superview!.convertRect(fromView.frame, toView: containerView)
            vc.targetRectangle.origin.y += fromView.bounds.height
            vc.targetRectangle.origin.y += yOffset
            if let height = height {
                vc.MAX_HEIGHT = height
            }
            parentViewController.fadeInViewController(vc, containerView)
        }
    }
    
    /**
     Setup UI
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Position the table
        tableHeight.constant = min(MAX_HEIGHT, CELL_HEIGHT * CGFloat(items.count) + EXTRA_VERTICAL_MARGINS * 2)
        tableWidth.constant = targetRectangle.width
        tableLeftMargin.constant = targetRectangle.origin.x
        tableTopMargin.constant = targetRectangle.origin.y
        
        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        tableView.rowHeight = CELL_HEIGHT
        
        tableContainer.roundCorners()
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    /**
     The number of rows
     
     - parameter tableView: the tableView
     - parameter section:   the section index
     
     - returns: the number of items
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    /**
     Get cell
     
     - parameter tableView: the tableView
     - parameter indexPath: the indexPath
     
     - returns: cell
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: DropdownViewCell.self)
        let item = items[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.selectionView.backgroundColor = UIColor.clearColor()
        if selectedItem?.id == item.id {
            cell.selectionView.backgroundColor = SELECTED_ITEM_COLOR
        }
        return cell
    }
    
    /**
     Cell selection handler
     
     - parameter tableView: the tableView
     - parameter indexPath: the indexPath
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedItem = items[indexPath.row]
        tableView.reloadData()
        delegate?.dropdownItemSeleced(self, selectedItem: selectedItem!)
    }
    
    /**
     Overlay button action handler
     
     - parameter sender: the button
     */
    @IBAction func overlayButtonAction(sender: AnyObject) {
        delegate?.dropdownCanceled(self)
    }
}

/**
 * Cell for table in DropdownViewController
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
class DropdownViewCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    
    /**
     Setup UI
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        self.backgroundColor = self.contentView.backgroundColor
        selectionView.roundCorners()
    }
}
