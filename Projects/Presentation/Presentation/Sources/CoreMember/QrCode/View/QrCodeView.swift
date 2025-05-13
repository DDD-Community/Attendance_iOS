//
//  QrCodeView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem

struct QRScannerView: View {
  var onClose: (() -> Void)?
  var backAction: () -> Void = {}
  @Bindable var store: StoreOf<QrCode>
  
  init(
    store: StoreOf<QrCode>,
    onClose: ( () -> Void)? = nil,
    backAction: @escaping () -> Void
  ) {
    self.store = store
    self.onClose = onClose
    self.backAction = backAction
  }
  
  var body: some View {
    ZStack {
      // 1. 카메라 미리보기 + 데이터 스캐너
      QRScannerRepresentable(
        shouldStartScanning: $store.isScanning,
        scannedText: $store.scannedText,
        dataToScanFor: [.barcode(symbologies: [.qr])]
      )
      .ignoresSafeArea()
      
      GeometryReader { proxy in
        let width = proxy.size.width
        let height = proxy.size.height
        // 화면 중앙에 scannerSize 크기의 네모 영역을 배치하기 위한 좌표 계산
        let rectX = (width - store.scannerSize) / 2
        let rectY = (height - store.scannerSize) / 2
        
        // (A) 반투명 오버레이 + 중앙 네모 영역은 투명하게
        Color.black.opacity(0.5)
          .mask(
            ZStack {
              Rectangle()  // 전체 화면 채움
              RoundedRectangle(cornerRadius: 12)
                .frame(width: store.scannerSize, height: store.scannerSize)
                .position(x: rectX + store.scannerSize / 2,
                          y: rectY + store.scannerSize / 2)
                .blendMode(.destinationOut)
            }
          )
          .compositingGroup()
          .ignoresSafeArea()
        
        // (B) 안내 문구 (네모 영역 위쪽에 배치)
        Text("QR 코드를 스캔해 주세요")
          .pretendardCustomFont(textStyle: .body1NormalMedium)
          .foregroundColor(.staticWhite)
          .font(.headline)
          .position(x: width / 2, y: rectY - 30)
        
        // (C) 중앙 테두리 (네모 영역 강조)
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.white, lineWidth: 2)
          .frame(width: store.scannerSize, height: store.scannerSize)
          .position(x: rectX + store.scannerSize / 2,
                    y: rectY + store.scannerSize / 2)
        
        // (D) 스캔된 텍스트 표시 (네모 영역 아래쪽)
        if !store.scannedText.isEmpty {
          Text("Scanned: \(store.scannedText)")
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .position(x: width / 2, y: rectY + store.scannerSize + 40)
        }
      }
      
      // 3. 왼쪽 상단 닫기 버튼
      VStack {
        HStack {
          Button {
            backAction()
          } label: {
            Image(asset: .closeGray)
              .resizable()
              .scaledToFit()
              .frame(width: 36, height: 36)
          }
          Spacer()
        }
        Spacer()
      }
      .padding(24)
    }
    .onChange(of: store.scannedText) { oldValue ,newValue in
      // 스캔된 텍스트가 업데이트되면, 2초 후에 재스캔을 위해 상태 재활성화
      if !newValue.isEmpty {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          store.scannedText = ""
          store.isScanning = true
        }
      }
    }
  }
}
