//
//  ReviewCategoryViewController.swift
//  ACRA-iOS
//
//  Created by Ankit Luthra on 2/19/17.
//  Copyright © 2017 Team Amazon. All rights reserved.
//

import Foundation
import UIKit

class ReviewCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleView: UINavigationItem!
    var categories = [String]()
    var selectedAsin = String()
    var selectedProductTitle = String()
    var reviews = Reviews()
    var selectedCategory = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title in navigation bar
        self.titleView.title = "Review Category"
        
        // Set the prompt(text above title) in navigation bar
        self.navigationItem.prompt = selectedProductTitle.substring(to: selectedProductTitle.index(selectedProductTitle.startIndex, offsetBy: setOffSet()))
        
        tableView.tableFooterView = UIView()
        
        categories = ["Product Quality", "Non Product Quality"]
        print("Reivew Category View: " + self.selectedAsin)
        
        APIModel.sharedInstance.getReviews(escape: self.selectedAsin) { (success:Bool) in
            if success {
                print("Successfully got reviews")
                DispatchQueue.main.async {
                    for review in Reviews.sharedReviews.posReviews {
                        
                        self.reviews.addReview(review: review)
                    }
                    for review in Reviews.sharedReviews.negReviews {
                        
                        self.reviews.addReview(review: review)
                    }
                    for review in Reviews.sharedReviews.irReview {
                        self.reviews.addReview(review: review)
                    }
                    self.tableView.reloadData()
                }
                
            } else {
                print("Product API call broke")
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        if(cell.textLabel?.text == "Product Quality"){
//            cell.detailTextLabel?.text = "472"
            let relCount = self.reviews.posReviews.count + self.reviews.negReviews.count
            print("review number: ", relCount)
//            print("relevent number: ", self.reviews.reReviews.count)
            cell.detailTextLabel?.text = String(relCount)
        }
        else if(cell.textLabel?.text == "Non Product Quality"){
//            cell.detailTextLabel?.text = "53"
            cell.detailTextLabel?.text = String(self.reviews.irReview.count)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let DestViewController: ReviewListTable = segue.destination as! ReviewListTable
            let selectedRow = tableView.indexPathForSelectedRow?.row
            DestViewController.selectedCategory = categories[selectedRow!]
            DestViewController.reviews = self.reviews
            DestViewController.selectedProductTitle = self.selectedProductTitle



    }
    
    // function to set the offSet for the prompt
    func setOffSet()  -> Int {
        // variable that stores '55' which we are considerng as the maximum length of the title
        let maxLength = 55
        //if title is more than maxLength then return the max string length
        if (selectedProductTitle.characters.count >= maxLength) {
            return maxLength
        } else {
            return selectedProductTitle.characters.count
        }
    }

    

    
    
}
