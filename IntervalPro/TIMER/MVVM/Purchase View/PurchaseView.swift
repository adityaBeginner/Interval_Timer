import SwiftUI
import StoreKit

struct PurchaseView: View {
    // Subscription Identifiers
    private let oneTimePurchaseID = AppComman.shared.oneTimePurchaseProductID
    
    // Color Theme
    private let themeColor = Color(hex: "#FF9C1A")
    
    //MARK: - STATE PROPERTIES
    ///
    /// State variables to manage UI state
    ///
    @State var product: SKProduct?
    @State var isPurchasing = false
    @State var showAlert = false
    @State var alertMessage = ""
    @State var isLoading = false  // Loading spinner state
    @Environment(\.presentationMode) var presentationMode
    
    
    
    private let coordinator = Coordinator()
    
    //MARK: - VIEWS
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            setup()
                .navigationBarBackButtonHidden(true)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Purchase Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .onAppear {
                    // Set up the coordinator to handle StoreKit delegates
                    coordinator.setup(self)
                    fetchProduct()
                }
            
            
            // Overlay the loader when isLoading is true
            if isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Loading...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .shadow(radius: 10)
                //                    .onAppear{ DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {isLoading = false})}
                
            }
        }
        
    }
    
    // MARK: - Fetch Product Details
    private func fetchProduct() {
        isLoading = true
        //Change to one time Subscription Id
        let request = SKProductsRequest(productIdentifiers: Set([oneTimePurchaseID]))
        request.delegate = coordinator
        request.start()
    }
    
    // MARK: - One Time Purchase Functions
    private func oneTImePurchase() {
        guard let product = product else { return }
        isLoading = true
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        isPurchasing = true
    }
    
    private func restorePurchases() {
        // isLoading = true
        // SKPaymentQueue.default().restoreCompletedTransactions()
        // isPurchasing = true
        verifyReceipt()
    }
    
    // MARK: - Receipt Verification
    func verifyReceipt() {
        isLoading = true
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            alertMessage = "No receipt found try again."
            showAlert = true
            isLoading = false
            
            let request = SKReceiptRefreshRequest()
            request.delegate = coordinator
            request.start()
            
            return
        }
        
        let receiptString = receiptData.base64EncodedString(options: [])
        
        let requestData: [String: Any] = [
            "receipt-data": receiptString,
            "password": AppComman.shared.verifyReceiptPassword
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData) else {
            alertMessage = "Invalid receipt data."
            showAlert = true
            isLoading = false
            return
        }
        
        let productionURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        verifyReceiptWithURL(productionURL, jsonData: jsonData, sandboxFallback: true)
    }
    
    private func verifyReceiptWithURL(_ url: URL, jsonData: Data, sandboxFallback: Bool) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false  // Hide loading indicator when verification completes
                
                guard let data = data, error == nil else {
                    self.alertMessage = "Failed to verify receipt."
                    self.showAlert = true
                    return
                }
                
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = jsonResponse["status"] as? Int {
                    
                    if status == 0 {
                        self.alertMessage = "Purchase verified successfully!"
                        // For one-time purchases, check receipt.in_app array
                        if let receipt = jsonResponse["receipt"] as? [String: Any],
                           let inAppArray = receipt["in_app"] as? [[String: Any]] {
                            self.parseOneTimePurchaseInfo(inAppArray)
                        } else {
                            self.alertMessage = "No purchase found in receipt."
                        }
                        
                    } else if status == 21007, sandboxFallback {
                        let sandboxURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
                        self.verifyReceiptWithURL(sandboxURL, jsonData: jsonData, sandboxFallback: false)
                        return
                    } else {
                        self.alertMessage = "Purchase verification failed. Status code: \(status)"
                    }
                } else {
                    self.alertMessage = "Unexpected response from Apple."
                }
                self.showAlert = true
            }
        }.resume()
    }
    
    private func parseOneTimePurchaseInfo(_ receiptInfo: [[String: Any]]) {
        for item in receiptInfo {
            if let productId = item["product_id"] as? String, productId == oneTimePurchaseID {
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
                    return
                }
                break
            }
        }
    }
}
//MARK: - Extension of Purchase View for child View
extension PurchaseView{
    @ViewBuilder
    func setup()-> some View{
        VStack{
            headerContent()
            Spacer()
            descriptionContent()
            Spacer()
            hightlightPurchaseText()
            appStorePurchaseBtn()
                .padding(.bottom, 24)
            footerBackground()
        }
        .edgesIgnoringSafeArea(.bottom)
        
    }
    
    //Content sub Views- header, app icon, App Name
    @ViewBuilder
    func headerContent()->some View{
        VStack{
            ComHeaderView(titleHeader: .constant("Unlock Full Version"), isBackBtnHidden: false, isSettingBtnHidden: true)
            Image(.pbIntervalAppIcon)
            TextLabelBoldFont(stringData: "Intervals", fontSize: .TSIZE_14)
        }
        .padding(.horizontal, 16)
    }
    
    //Description Content contains: payment description and features description
    @ViewBuilder
    func descriptionContent()-> some View{
        VStack(spacing: 25){
            paymentDescription()
            
            featuresDescription()
        }
        .padding(.horizontal)
    }
    
    //Payment Description
    @ViewBuilder
    func paymentDescription()->some View{
        VStack(spacing: 8){
            TextLabelBoldFont(stringData: "UPGRADE", fontSize: .TSIZE_24)
            TextLabelMeduimFont(stringData: "Unlock all the features with a one-time payment of \(product?.priceLocale.currencySymbol ?? "")\(product?.price ?? 0.0)")
                .multilineTextAlignment(.center)
                .lineLimit(nil) // ← allow multiple lines
                .fixedSize(horizontal: false, vertical: true) // ← prevent truncation
                .padding(.horizontal)
                .minimumScaleFactor(0.75)
        }
    }
    
    //Features Description
    @ViewBuilder
    func featuresDescription()->some View{
        VStack(alignment: .leading,spacing: 18){
            HStack(spacing: 12){
                Image(.appPurchaseCheckMark)
                TextLabelRegularFont(stringData: "Unlimited Timer Creation", fontSize: .TSIZE_16)
            }
            HStack(spacing: 12){
                Image(.appPurchaseCheckMark)
                TextLabelRegularFont(stringData: "Free Timers Installed", fontSize: .TSIZE_16)
            }
            HStack(spacing: 12){
                Image(.appPurchaseCheckMark)
                TextLabelRegularFont(stringData: "Import CSV Function", fontSize: .TSIZE_16)
            }
            HStack(spacing: 12){
                Image(.appPurchaseCheckMark)
                TextLabelRegularFont(stringData: "Export CSV Function", fontSize: .TSIZE_16)
            }
            HStack(spacing: 12){
                Image(.appPurchaseCheckMark)
                TextLabelRegularFont(stringData: "Enable Hundredths of a Second", fontSize: .TSIZE_16)
            }
            HStack(spacing: 12){
                Image(.appPurchaseCheckMark)
                TextLabelRegularFont(stringData: "Lifetime Access - No Recurring Fees", fontSize: .TSIZE_16)
            }
        }
    }
    
    //Purchase Button
    @ViewBuilder
    func appStorePurchaseBtn()-> some View{
        VStack(spacing: 12){
            
            //Purchase Btn
            Button(action:{
                oneTImePurchase()
            } ){
                roundedRectangleButton()
            }
            .disabled(product == nil)
            
            // Restore Subscription Button
            Button(action: {
                restorePurchases()
            }) {
                VStack(spacing: 1){
                    TextLabelBoldFont(stringData: "Restore Purchase" , fontColor: .noteBoxBorder, fontSize: .TSIZE_14)
                    HStack{
                        Color.noteBoxBorder
                    }
                    .frame(width: 125,height: 1)
                }
            }
        }
    }
    
    //Apple Light higlight text for subscription
    func hightlightPurchaseText()-> some View{
        Text("Unlock all features with a one-time payment of \(product?.priceLocale.currencySymbol ?? "")\(product?.price ?? 0.0)")
            .font(.system(size: 12))
            .foregroundStyle(Color.black)
    }
    
    
    //AppleStoreBtnDesign
    @ViewBuilder
    func roundedRectangleButton() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.black)
            .frame(width: 161.6, height: 52.61)
            .overlay {
                HStack {
                    Image(systemName: "cart.fill") // Replace with any relevant icon
                        .foregroundColor(.white)
                        .imageScale(.large)
                    VStack(alignment: .leading) {
                        Text("One-Time Purchase")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        
                        Text("\(product?.priceLocale.currencySymbol ?? "")\(product?.price ?? 0.0)") // Dynamic price from StoreKit
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white)
                    .frame(width: 164, height: 55)
            }
    }
    
    //Footer Background
    @ViewBuilder
    func footerBackground()->some View{
        HStack{
            Color(uiColor: .footerBackgroundColor)
        }
        .frame(height: 8)
    }
}


// MARK: - Coordinator
class Coordinator: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private var parent: PurchaseView?
    
    func setup(_ parent: PurchaseView) {
        self.parent = parent
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.parent?.isLoading = false
            if let fetchedProduct = response.products.first {
                self.parent?.product = fetchedProduct
            } else {
                self.parent?.alertMessage = "Failed to load product details."
                self.parent?.showAlert = true
            }
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async {
            for transaction in transactions {
                switch transaction.transactionState {
                    case .purchased:
                        debugPrint("Purchase Count")
                        self.parent?.verifyReceipt()
                        SKPaymentQueue.default().finishTransaction(transaction)
                        self.parent?.isPurchasing = false
                        self.parent?.isLoading = false
                    case .restored:
                        debugPrint("Restore Count")
                        //                    self.parent?.verifyReceipt()
                        SKPaymentQueue.default().finishTransaction(transaction)
                        self.parent?.isPurchasing = false
                        self.parent?.isLoading = false
                    case .failed:
                        self.parent?.alertMessage = transaction.error?.localizedDescription ?? "Purchase failed."
                        self.parent?.showAlert = true
                        SKPaymentQueue.default().finishTransaction(transaction)
                        self.parent?.isPurchasing = false
                        self.parent?.isLoading = false
                    default:
                        break
                }
            }
        }
    }
    
    // Restore if Token not exist
    func requestDidFinish(_ request: SKRequest) {
        debugPrint("Receipt refresh completed successfully.")
        
        if Bundle.main.appStoreReceiptURL == nil
//            ,FileManager.default.fileExists(atPath: receiptURL.path)
        {
       //     self.parent?.verifyReceipt()
            debugPrint("Recipt Url not found")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Receipt refresh failed: \(error.localizedDescription)")
    }
    
    // ✅ Called once when restore finishes
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            self.parent?.verifyReceipt()
            //
            debugPrint("Purchase restore sucessfully")
        }
    }
}

// MARK: - Helper for SKProduct Price Formatting
extension SKProduct {
    var localizedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
}

// MARK: - Preview Provider
struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
    }
}
