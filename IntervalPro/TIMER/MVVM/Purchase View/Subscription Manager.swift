//
//  Subscription Manager.swift
//  TIMER
//
//  Created by Aditya Maroo on 11/10/24.
//

import Foundation
import StoreKit

class SubscriptionManager: NSObject, ObservableObject {
    
    static let shared = SubscriptionManager()
    private let oneTimePurchaseProductID = AppComman.shared.oneTimePurchaseProductID
    
    
    // MARK: - Fetch Subscription Details
    func fetchSubscriptionStatus() {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            print("No receipt URL found")
            return
        }
        
        if FileManager.default.fileExists(atPath: receiptURL.path) {
            // The receipt exists, read and send to Apple server for validation
            verifyReceipt(receiptURL: receiptURL)
        } else {
            // Receipt does not exist, request it
            SKReceiptRefreshRequest().start()
        }
    }
    
    // MARK: - Verify Receipt
    private func verifyReceipt(receiptURL: URL) {
        do {
            let receiptData = try Data(contentsOf: receiptURL).base64EncodedString()
            let requestContents: [String: Any] = [
                "receipt-data": receiptData,
                "password": AppComman.shared.verifyReceiptPassword, // replace with your app's shared secret
            ]
            
            let requestData = try JSONSerialization.data(withJSONObject: requestContents, options: .prettyPrinted)
            let storeURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
            
            var request = URLRequest(url: storeURL)
            request.httpMethod = "POST"
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Receipt verification error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        self.handleReceiptResponse(jsonResponse)
                    }
                } catch {
                    print("Failed to parse receipt verification response: \(error)")
                }
            }
            task.resume()
        } catch {
            print("Failed to load receipt data: \(error)")
        }
    }
    
    // MARK: - Handle Receipt Response
    private func handleReceiptResponse(_ response: [String: Any]) {
        guard let status = response["status"] as? Int else { return }
        
        if status == 21007 {
            // Sandbox receipt, reverify with the sandbox URL
            reverifyWithSandbox(response)
            return
        }
        
        if status == 0, let receiptInfo = response["latest_receipt_info"] as? [[String: Any]] {
            parseReceiptInfo(receiptInfo)
        } else {
            print("Receipt verification failed with status: \(status)")
        }
    }
    
    private func reverifyWithSandbox(_ response: [String: Any]) {
        let storeURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL).base64EncodedString() else { return }
        
        let requestContents: [String: Any] = [
            "receipt-data": receiptData,
            "password": AppComman.shared.verifyReceiptPassword,
        ]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestContents, options: .prettyPrinted)
            var request = URLRequest(url: storeURL)
            request.httpMethod = "POST"
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Sandbox re-verification error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        self.handleReceiptResponse(jsonResponse)
                    }
                } catch {
                    print("Failed to parse sandbox re-verification response: \(error)")
                }
            }
            task.resume()
        } catch {
            print("Failed to create sandbox re-verification request: \(error)")
        }
    }
    
    private func parseReceiptInfo(_ receiptInfo: [[String: Any]]) {
        for item in receiptInfo {
            if let productId = item["product_id"] as? String, productId == oneTimePurchaseProductID{
                if let transactionId = item["transaction_id"] as? String,
                   let purchaseDateMs = item["purchase_date_ms"] as? String {
                    
                    let purchaseDate = Date(timeIntervalSince1970: Double(purchaseDateMs)! / 1000.0)
                    ///
                    /// SAVE USERS SUBSCRIPTION INFO
                    /// IN USER DEFAULTS
                    ///
                    AppDefaults.shared.isUserSubscribed = true
                    
                    
                    
                    if !UserDefaults.standard.contains(key: "isPaidFolderAlreadyExist"){
                        AppDefaults.shared.isPaidFolderAlreadyExist = true
                        ImportCSV.shared.paidAllCsvFolderFile()
                    }
                    
                    
                    debugPrint("One-time purchase verified:")
                    debugPrint("Transaction ID: \(transactionId)")
                    debugPrint("Purchase Date: \(purchaseDate)")
                    break
                }
            }
        }
    }
}

