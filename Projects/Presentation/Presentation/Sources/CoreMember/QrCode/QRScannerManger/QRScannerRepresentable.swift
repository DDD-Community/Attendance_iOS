//
//  QRScannerRepresentable.swift
//  Presentation
//
//  Created by Wonji Suh  on 4/6/25.
//

import SwiftUI
import VisionKit

import LogMacro

struct QRScannerRepresentable: UIViewControllerRepresentable {
  @Binding var shouldStartScanning: Bool
  @Binding var scannedText: String
  
  var dataToScanFor: Set<DataScannerViewController.RecognizedDataType>
  
  // MARK: - Coordinator
  class Coordinator: NSObject, DataScannerViewControllerDelegate {
    var parent: QRScannerRepresentable
    
    init(_ parent: QRScannerRepresentable) {
      self.parent = parent
    }
    
    // 사용자가 탭했을 때 호출 (원한다면 사용)
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
      switch item {
      case .text(let text):
        parent.scannedText = text.transcript
      case .barcode(let barcode):
        parent.scannedText = barcode.payloadStringValue ?? "Unable to decode the scanned code"
      default:
        #logDebug("Unexpected item")
      }
    }
    
    // 인식된 아이템이 업데이트될 때 호출됨
    func dataScanner(_ dataScanner: DataScannerViewController,
                     didUpdate items: [RecognizedItem],
                     allItems: [RecognizedItem]) {
      #logDebug("인식된 아이템: \(items)")
      for item in items {
        if case let .barcode(barcode) = item {
          #logDebug("QR 코드 인식됨: \(barcode.payloadStringValue ?? "nil")")
          parent.scannedText = barcode.payloadStringValue ?? "Unable to decode the scanned code"
          // 비동기 방식으로 스캔 중지
          DispatchQueue.main.async {
            dataScanner.stopScanning()
          }
          break
        }
      }
    }
  }
  
  // MARK: - UIViewControllerRepresentable
  func makeUIViewController(context: Context) -> DataScannerViewController {
    let dataScannerVC = DataScannerViewController(
      recognizedDataTypes: dataToScanFor,
      qualityLevel: .accurate,
      recognizesMultipleItems: true,
      isHighFrameRateTrackingEnabled: true,
      isPinchToZoomEnabled: true,
      isGuidanceEnabled: true,
      isHighlightingEnabled: true
    )
    dataScannerVC.delegate = context.coordinator
    return dataScannerVC
  }
  
  func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    let isScanning = uiViewController.isScanning
    if shouldStartScanning, !isScanning {
      do {
        try uiViewController.startScanning()
      } catch {
        #logDebug("Failed to start scanning: \(error)")
      }
    } else if !shouldStartScanning, isScanning {
      uiViewController.stopScanning()
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  // startScanning() 호출을 비동기 함수로 감싸기 위한 래퍼
  private func startScanningAsync(_ uiViewController: DataScannerViewController) async throws {
    try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.main.async {
        do {
          try uiViewController.startScanning()
          continuation.resume(returning: ())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
