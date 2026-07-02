//
//  OpenDocumentPicker.swift
//  TIMER
//
//  Created by Aditya Maroo on 03/10/24.
//

import SwiftUI
import UIKit

// MARK: - ShareCSV View
struct ShareCSV: View {
    @Binding var isPresentedShare: Bool

    var body: some View {
        if let url = ExportCSV.shared.csvFileURL, FileManager.default.fileExists(atPath: url.path) {
            OpenShareActivityView(fileURL: url, isPresentedShare: $isPresentedShare)
        } else {
            ToastEditView(isToastHidden: .constant(true)) // Fallback for invalid file
        }
    }
}

// MARK: - OpenShareActivityView (UIViewControllerRepresentable)
private struct OpenShareActivityView: UIViewControllerRepresentable {
    var fileURL: URL
    @Binding var isPresentedShare: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            // For iPads, set up the popover presentation
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                self.isPresentedShare = false // Dismiss the activity view
            }
            
            // Present the activity view controller
            viewController.present(activityViewController, animated: true, completion: nil)
        }
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update needed
    }

    // MARK: - Coordinator (Optional, not used here but for potential state handling)
    class Coordinator: NSObject {
        var parent: OpenShareActivityView

        init(_ parent: OpenShareActivityView) {
            self.parent = parent
        }
    }
}
