//
//  ProductViewController.swift
//  ACRA-iOS
//
//  Created by Ankit Luthra on 2/16/17.
//  Copyright © 2017 Team Amazon. All rights reserved.
//

import Foundation
import UIKit

// Call API mode first to load data
// data can be stored into a Products object

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
  
    var menuShowing = false
    
    //IBAction to handle the  animation of the sort menu when button is clicked.
    @IBAction func sortMenuTrigger(_ sender: Any) {
        if(menuShowing) {
            //setting the trailing constant to -180. For hiding the menu.
            trailingConstraint.constant = -180
            // Animation effect of 0.4 seconds
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
                //setting the background button alpha to 0 so that user can use the tableview behind it.
                self.backgroundButton.alpha = 0
            })
        }
        else {
            trailingConstraint.constant = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
                //setting the background button alpha to 0.5 so that button gets activated when menu is showing.
                self.backgroundButton.alpha = 0.5
            })
        }
        menuShowing = !menuShowing
    }

    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var sortTableView: UITableView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageDisplay: UITextField!
    
    var SearchLabel = String()
    var products: [Product] = []
    var selectedAsinProduct = String()
    var selectedProductName = String()
    let fullStarImage:  UIImage = UIImage(named: "starFull.png")!
    let halfStarImage:  UIImage = UIImage(named: "starHalf.png")!
    let emptyStarImage: UIImage = UIImage(named: "starEmpty.png")!
    
    var productRating = Double()
    
    var sortByPrice = ["High to Low","Low to High"]
    var sortByRating = ["High to Low","Low to High"]
    var sortRule = String()
    
    var finishedLoading = false
    var viewApperBool = false
    

    //Sorting options icon by Icons8: https://icons8.com/web-app/18636/Sorting-Options
    //Thanks to Icons8 for Price Tag USD icon: https://icons8.com/web-app/2971/Price-Tag-USD
    //Thanks to Icons8 for the Rating icon: https://icons8.com/web-app/11674/Rating
    let sectionImages: [UIImage] = [#imageLiteral(resourceName: "Sorting"), #imageLiteral(resourceName: "Price Tag"), #imageLiteral(resourceName: "Rating")]
    
    //section headers
    let sections: [String] = ["Sort By", "Price", "Rating"]
    
    //Data for sections headers
    let s1Data: [String] = []
    let s2Data: [String] = ["High to Low", "Low to High"]
    let s3Data: [String] = ["High to Low", "Low to High"]
    
    var sectionData: [Int: [String]] = [:]
    
    // function to set when the loading is finished for loading animation
    func setFinishedLoading(setTo: Bool){
        finishedLoading = setTo
    }
    
    // function to get the loading to check if it is finished or not for loading animation
    func getFinishedLoading() -> Bool{
        return finishedLoading
    }
    
    //display product's star image based on rating
    func getStarImage(starNumber: Double, forRating rating: Double) -> UIImage {
        if rating >= starNumber {
            return fullStarImage
        } else if rating + 1 > starNumber {
            return halfStarImage
        } else {
            return emptyStarImage
        }
    }
    
    // set sort menu hidden
    func setMenuToHidden() {
        trailingConstraint.constant = -180
        menuShowing = false
        backgroundButton.alpha = 0
    }
    
    // when no product found, set dog image as background
    func setDogImg (viewName: UITableView) {
        let image = UIImage(named: "dog")
        let noDataImage = UIImageView(image: image)
        viewName.backgroundView = noDataImage
    }

    // delay 2 second for product result untill get data from server
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Products.sharedProducts.clearProducts()
        
        viewApperBool = true
        if(self.getFinishedLoading()==true){
            print("stop animation")
            self.activityIndicator.stopAnimating()
            self.messageDisplay.isHidden = true
        }
        else if(self.getFinishedLoading()==false){
            let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                //code with delay
                if(self.productTableView.numberOfRows(inSection: 0) == 0) {
                    print("seting dog")
                    self.messageDisplay.isHidden=false
                    self.setDogImg(viewName: self.productTableView)
                    self.activityIndicator.stopAnimating()
                }
            }
            
        }
        
       print("viewdidappear")
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMenuToHidden()
        sortTableView.backgroundColor = UIColor (red: CGFloat(237/255.0), green: CGFloat(250/255.0), blue: CGFloat(255/255.0), alpha: 1.0)

        //for rounded corners
        sortTableView.layer.cornerRadius = 10
        sortTableView.layer.masksToBounds = true
       
        sectionData = [0:s1Data, 1:s2Data, 2:s3Data]
        
        //clear previous products
        Products.sharedProducts.clearProducts()

        let escapedString = self.SearchLabel.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        activityIndicator.startAnimating()
        
        // call api to get data and push into local database
        APIModel.sharedInstance.getProducts(escape: escapedString!) { (success:Bool) in
            if success {
                print("Successfully got products")
                DispatchQueue.main.async {
                    for product in Products.sharedProducts.products {
                        self.products.append(product)
                    }
                    self.productTableView.reloadData()
                    if(self.viewApperBool){
                        self.activityIndicator.isHidden = true
                    }
                }
            } else {
                print("Product API call broke")
            }
        }
        navigationTitle.title = "Products"
        
        productTableView.tableFooterView = UIView()
        sortTableView.tableFooterView = UIView()
    }
    
    //load image based on given url
    func get_image(_ urlString:String) -> UIImage {
        let strurl = NSURL(string: urlString)!
        let dtinternet = NSData(contentsOf:strurl as URL)!
        return UIImage(data: dtinternet as Data)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // return the number of products got from server, if 0 set dog image
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if(tableView == productTableView) {
            if(self.products.count == 0){
                return 0
            }
            else {
                productTableView.backgroundView = nil
            
                return self.products.count
            }
        }
        else {
            return (sectionData[section]?.count)!
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == sortTableView){
            return sections.count
        }
        //when the table is other than the sorting menu table we do not nead header so return 1
        else {
            return 1
        }
    }
    
    //load product cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cell for row at")
        if(tableView == productTableView) {
            let cell = self.productTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
        
            cell.photo.image = get_image(self.products[indexPath.row].image_url)
            cell.name.text = self.products[indexPath.row].title
            cell.price.text = self.products[indexPath.row].price_string
            // sets the star rating image according to the rating  provided.
            if let productRating = self.products[indexPath.row].rating {
                cell.star1.image = getStarImage(starNumber: 1, forRating: productRating)
                cell.star2.image = getStarImage(starNumber: 2, forRating: productRating)
                cell.star3.image = getStarImage(starNumber: 3, forRating: productRating)
                cell.star4.image = getStarImage(starNumber: 4, forRating: productRating)
                cell.star5.image = getStarImage(starNumber: 5, forRating: productRating)
            }
            // rounded value of rating for displaying the rating next to star rating.
            let rounded_rating = Double(round(100*(self.products[indexPath.row].rating))/100)
            cell.ratingValue.text = "(" + String(rounded_rating) + ")"
            setFinishedLoading(setTo: true)
            
            return cell
        }
        //Sort menu
        else {
            var cell2 = tableView.dequeueReusableCell(withIdentifier: "SortCell")
            
            if cell2 == nil {
                cell2 = UITableViewCell(style: .default, reuseIdentifier: "SortCell");
            }
            
            cell2!.textLabel?.text = sectionData[indexPath.section]![indexPath.row]
            
            cell2?.backgroundColor = UIColor (red: CGFloat(237/255.0), green: CGFloat(250/255.0), blue: CGFloat(255/255.0), alpha: 1.0)
            return cell2!
        }
    }
    
    // Get which selected from table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == productTableView ) {
            print("selected asin: " + self.products[indexPath.row].asin)
            self.selectedAsinProduct = self.products[indexPath.row].asin
            self.selectedProductName = self.products[indexPath.row].title
            self.performSegue(withIdentifier: "ProductToCategory", sender: nil)
            setMenuToHidden()
        }
        
        // sort menu
        if(tableView == sortTableView) {
            if(indexPath.section == 1) {
                switch indexPath.row {
                    case 0:
                        print("Sec:1 Row: 0 ->", indexPath.section , indexPath.row)
                        self.products = self.products.sorted{$0.price_int > $1.price_int}
                    case 1:
                        print("Sec:1 Row: 1 ->", indexPath.section , indexPath.row)
                        self.products = self.products.sorted{$0.price_int < $1.price_int}
                    default:
                        break
                    }
                }
            else if(indexPath.section == 2) {
                switch indexPath.row {
                    case 0:
                        print("Sec:2 Row: 0 ->", indexPath.section , indexPath.row)
                        self.products = self.products.sorted{$0.rating > $1.rating}
                    case 1:
                        print("Sec:2 Row: 1 ->", indexPath.section , indexPath.row)
                        self.products = self.products.sorted{$0.rating < $1.rating}
                    default:
                        break
                }
            }
            setMenuToHidden()
            productTableView.reloadData()
        }
    }
    
    // display sort menu
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (tableView == sortTableView){
            let cellHeader = sortTableView.dequeueReusableCell(withIdentifier: "HeaderCell\(section)") as! HeaderCellProductSort
            cellHeader.setupCell(image: sectionImages[section], labelText: sections[section])
            return cellHeader
        }
        else {
            return nil
        }
    }

    // function to set the heght for header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView == sortTableView) {
            if(section==0){
                return 45
            }
            else{
                return 41
            }
            
        }
        else {
            return 0
        }
    }
    
    
    
    // pass selected product item to review controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProductToCategory"){
            let DestViewController: ReviewCategoryViewController = segue.destination as! ReviewCategoryViewController
            DestViewController.selectedAsin = self.selectedAsinProduct
            DestViewController.selectedProductTitle = self.selectedProductName
            DestViewController.products.products = self.products
            
            for product in self.products {
                if DestViewController.similarProducts.count < 11 && product.asin != self.selectedAsinProduct{
                    
                    DestViewController.similarProducts.append(product)
                }
            }
            print("Prouct View Controller: " + DestViewController.selectedAsin)
        }
    }
    
    
}
