/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import StoreKit

class ChoiceTestVC: UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    @available(iOS 3.0, *)
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction: SKPaymentTransaction in transactions {
            
            guard let error = transaction.error as? SKError else {return}
            
            switch transaction.transactionState {
                
                
            case .purchasing:
                print("Transaction state -> Purchasing")
                
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Transaction state -> Purchased successfully")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                restoreBtn.isHidden = false
                
            case .restored:
                print("Transaction state -> Restored")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if error.code == .paymentCancelled {
                    print("Transaction state -> Cancelled")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
            default:
                break
            }
        }
    }

    
    let app = (UIApplication.shared.delegate as? AppDelegate)
    let Product : SKProduct? = nil
    let kRemoveAdsProductIdentifier = "PTBE1NYSALES"
    let refreshRequest : SKReceiptRefreshRequest? =  nil
    var CurrentDateStr : String = ""
    
    
//    MARK: - IBOutlet
    
    @IBOutlet weak var DashBtn: UIButton!
    @IBOutlet weak var MarathonBtn: UIButton!
    @IBOutlet weak var sprintBtn: UIButton!
    @IBOutlet weak var imgsprint: UIImageView!
    @IBOutlet weak var lblSprint: UILabel!
    @IBOutlet weak var imgDash: UIImageView!
    @IBOutlet weak var lblDash: UILabel!
    @IBOutlet weak var lblMarathon: UILabel!
    @IBOutlet weak var imageMarathon: UIImageView!
    @IBOutlet weak var imgAD: UIImageView!
    @IBOutlet weak var btnAD: UIButton!
    
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearData()
        checkTime()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showAdImag), userInfo: nil, repeats: false)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func showAdImag() {
        
        print("AD : \((UserDefaults.standard.value(forKey: "adImage") as? String))")
        if (UserDefaults.standard.value(forKey: "adImage") as? String) == nil {
            btnAD.isEnabled = false
        }
        else {
            btnAD.isEnabled = true
            imgAD.load.request(with: URL(string: UserDefaults.standard.value(forKey: "adImage") as! String)!)
        }
        
    }
    
    func checkTime() {
        
        
        var timeInterval:NSInteger = 0
        
        let today = Date()
        print("today : \(today)")
        
        if UserDefaults.standard.value(forKey: "Tommorrow") as? NSDate == nil {
            
            let tommorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
            UserDefaults.standard.set(tommorrow, forKey: "Tommorrow")
            
            timeInterval = NSInteger(tommorrow!.timeIntervalSince(today))
            print("timeInterval : \(timeInterval)")
            
            callAdService()
            getVersion()
            
        }
        else {
            
            let nextdate = UserDefaults.standard.value(forKey: "Tommorrow") as! NSDate
            print("nextdate : \(nextdate)")
            
            timeInterval = NSInteger(nextdate.timeIntervalSince(today))
            print("timeInterval : \(timeInterval)")
            
            if timeInterval <= 0 {
                let tommorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                UserDefaults.standard.set(tommorrow, forKey: "Tommorrow")
                
                callAdService()
                getVersion()
            }
        }
        
    }

    func clearData()  {
        sprintBtn.isSelected = false
        lblSprint.textColor = UIColor.black
        imgsprint.isHidden = true
        
        DashBtn.isSelected = false
        lblDash.textColor = UIColor.black
        imgDash.isHidden = true
        
        MarathonBtn.isSelected = false
        lblMarathon.textColor = UIColor.black
        imageMarathon.isHidden = true
    }
    
    func GoToTest(testType: NSInteger)  {
        let ctvc = storyboard?.instantiateViewController(withIdentifier: "ShowQuestionVC") as! ShowQuestionVC
        if testType==1 {
            ctvc.typeTest = 1
        }
        else if testType == 2 {
            ctvc.typeTest = 2
        }
        else if testType == 3 {
            ctvc.typeTest = 3
        }
        navigationController?.pushViewController(ctvc, animated: true)
    }
    
    func callAdService() {
        let rechability = Reachability()
        
        if rechability?.isReachable == true {
            print("rechable")
            let strURL = "\((app?.strService)! as String)getAd"
            
            let url:NSURL = NSURL(string: strURL)!
            let session = URLSession.shared
            let urlReq = NSMutableURLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
            urlReq.httpMethod = "GET"
            
            urlReq.setValue("abc123", forHTTPHeaderField: "API_KEY")
            urlReq.setValue("\(UserDefaults.standard.value(forKey: "userEmail") as! String)", forHTTPHeaderField: "EMAIL_KEY")
            urlReq.setValue("\(UserDefaults.standard.value(forKey: "sessionKey") as! String)", forHTTPHeaderField: "SESSION_KEY")
            
            // make the request
            let task = session.dataTask(with: urlReq as URLRequest, completionHandler: { (data, response, error) in
                // do stuff with response, data & error here
                print(error ?? "")
                print(response ?? "NO Response")
                
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
                    
                    print("Response : \(jsonDict)")
                    if jsonDict.isEqual(nil) {
                        print("Error :\(error)")
                    }
                    else {
                        DispatchQueue.main.async {
                            
                            if (jsonDict.value(forKey: "adImageURL") as? String)  != nil {
                                
                                UserDefaults.standard.set(jsonDict.value(forKey: "adImageURL"), forKey: "adImage")
                                UserDefaults.standard.set(jsonDict.value(forKey: "adClickURL"), forKey: "adURL")
                                
                            }
                        }
                    }
                }
                    
                catch {
                    print(error)
                    return
                }
            })
            
            task.resume()
            
        }
            
        else {
            print("not rechable")
            showAlert(msg: "Make sure your device is connected to the internet.")
        }
        
    }
    

    
    func getVersion() {
        
        let rechability = Reachability()
        
        if rechability?.isReachable == true {
            print("rechable")
            let strURL = "\((app?.strService)! as String)getVersion"
            
            let url:NSURL = NSURL(string: strURL)!
            let session = URLSession.shared
            let urlReq = NSMutableURLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
            urlReq.httpMethod = "GET"
            
            urlReq.setValue("abc123", forHTTPHeaderField: "API_KEY")
            urlReq.setValue("\(UserDefaults.standard.value(forKey: "userEmail") as! String)", forHTTPHeaderField: "EMAIL_KEY")
            urlReq.setValue("\(UserDefaults.standard.value(forKey: "sessionKey") as! String)", forHTTPHeaderField: "SESSION_KEY")
            
            // make the request
            let task = session.dataTask(with: urlReq as URLRequest, completionHandler: { (data, response, error) in
                // do stuff with response, data & error here
                print(error ?? "")
                print(response ?? "NO Response")
                
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
                    
                    print("Response : \(jsonDict)")
                    if jsonDict.isEqual(nil) {
                        print("Error :\(error)")
                    }
                    else {
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(jsonDict["majorVersion"] as! NSInteger, forKey: "AppVersion")
                        }
                    }
                    //                self.actInd_showQst.stopAnimating()
                }
                catch {
                    return
                }
            })
            task.resume()
            
        }
        else {
            print("not rechable")
            
            showAlert(msg: "Make sure your device is connected to the internet.")
        }
    }
    
    func showAlert(msg:String)  {
        let alert = UIAlertController(title: "PassTheBrokerExam", message: msg, preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            
        }
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
//    MARK: - In Purchase
    
    func showAlertPurchase()  {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let alert = UIAlertController(title: "PassTheBrokerExam", message: "Get over 1,000 premium questions!", preferredStyle: .alert)
        
        let Buy = UIAlertAction(title: "Buy", style: .default) { (UIAlertAction) in
            SKPaymentQueue.default().add(self)
            self.appPurchase()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            
        }
        
        alert.addAction(Buy)
        alert.addAction(Cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkPurchasedItems() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if (request is SKReceiptRefreshRequest) {
            print("Got a new receipt... \(request.description)")
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Purchase Error : \(error)")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        var validProduct: SKProduct? = nil
        
        let count = Int(response.products.count)
        
        if count > 0 {
            validProduct = (response.products[0] as? SKProduct)
            print("Products Available!")
            purchase(validProduct!)
        }
        else if validProduct == nil {
            print("No products available")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            showAlert(msg: "No products to purchase")
            
            
        }
        
    }
    
    func provideContent(_ productId: String) {
        if (productId == kRemoveAdsProductIdentifier) {
            // enable the pro features
            UserDefaults.standard.set(true, forKey: "isStorePurchased")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    
    func purchase(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        print("restoreCompletedTransactionsFailedWithError \(error)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        showAlert(msg: "Restore Process Failed...")
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        print("\(queue)")
        print("Restored Transactions are once again in Queue for purchasing \(queue.transactions)")
        var purchasedItemIDs = [Any]()
        print("received restored transactions: \(UInt(queue.transactions.count))")
        for transaction: SKPaymentTransaction in queue.transactions {
            let productID: String = transaction.payment.productIdentifier
            purchasedItemIDs.append(productID)
        }
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        
        
        
         guard let error = transaction.error as? SKError else {return}
        
        if error.code != .paymentCancelled {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error.code == .clientInvalid {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //            [self showAlert:@"In-App Purchase" withMessage:INVALID_CLIENT];
            }
            else if error.code == .paymentInvalid {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //[self showAlert:@"In-App Purchase" withMessage:PAYMENT_INVALID];
            }
            else if error.code == .paymentNotAllowed {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //[self showAlert:@"In-App Purchase" withMessage:PAYMENT_NOT_ALLOWED];
            }
            else if error.code == .paymentCancelled {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                // [self showAlert:@"In-App Purchase" withMessage:@"This device is not allowed to make the payment."];
                print("User Cancellation.")
            }
            else {
                // SKErrorUnknown
                print("Unknown Reason.")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let alert = UIAlertView(title: "Transaction Status", message: "Transaction Failed due to unknown reason", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
                alert.show()
            }
        }
        else {
            
        }
    }
    
    func appPurchase() {

            print("premium")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            checkPurchasedItems()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            var todaysDate: Date?
            todaysDate = Date()
            print("Todays date is \(formatter.string(from: todaysDate!))")
            
            
            CurrentDateStr = "\(formatter.string(from: todaysDate!))"
            
            print("User requests to remove ads")
            if SKPaymentQueue.canMakePayments() {
                print("User can make payments")
                let productsRequest = SKProductsRequest(productIdentifiers:[kRemoveAdsProductIdentifier])
                
                productsRequest.delegate = self
                
                productsRequest.start()
            }
                
            else {
                print("User cannot make payments due to parental controls")
            }
            
        
    }

    
//MARK: -Action Method
    
    @IBAction func btnShowAd(_ sender: Any) {

        let strUrl = (UserDefaults.standard.value(forKey: "adURL") as! String)
        UIApplication.shared.openURL(URL(string: strUrl)!)
    }
    
    @IBAction func btnMarathonTest(_ sender: UIButton) {
        
        if sender.isSelected==true {
           sender.isSelected = false
            lblMarathon.textColor = UIColor.black
            imageMarathon.isHidden = true
        }
        else {
            clearData()
            sender.isSelected = true
            lblMarathon.textColor = UIColor.white
            imageMarathon.isHidden = false
//            GoToTest(testType: 3)
            showAlertPurchase()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            appPurchase()
            
        }
    }
    
    @IBAction func btnDashTest(_ sender: UIButton) {
        
        if sender.isSelected==true {
            sender.isSelected = false
            lblDash.textColor = UIColor.black
            imgDash.isHidden = true
        }
        else {
            clearData()
            sender.isSelected = true
            lblDash.textColor = UIColor.white
            imgDash.isHidden = false
//            GoToTest(testType: 2)
            showAlertPurchase()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            appPurchase()
        }
    }
    
    @IBAction func btnSprintTest(_ sender: UIButton) {
        
        if sender.isSelected==true {
            sender.isSelected = false
            lblSprint.textColor = UIColor.black
            imgsprint.isHidden = true
        }
        else {
            clearData()
            sender.isSelected = true
            lblSprint.textColor = UIColor.white
            imgsprint.isHidden = false
            GoToTest(testType: 1)
        }
    }
    @IBAction func btnMenu(_ sender: Any) {
        let mvc = storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        navigationController?.pushViewController(mvc, animated: false)
    }
}
