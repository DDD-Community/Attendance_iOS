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
      QrsccannerRepresentable(
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
        
        NavigationBackButton(buttonAction: backAction)
        
        if store.loadingQRImage == true {
          TooltipShape(tooltipText: store.qrCodeReaderText)
            .offset(y: UIScreen.screenHeight * 0.2)
        } else {
          TooltipShape(tooltipText: store.qrCodeReaderText)
            .offset(y: UIScreen.screenHeight * 0.2)
        }
        
        Spacer()
          .frame(height: 24)
        
        //              generateQrImage()
        
        creatEventButton()
        
        Spacer()
      }
      .navigationBarBackButtonHidden()
      .task {
        store.send(.view(.appearLoading))
        store.send(.async(.fetchEvent))
        store.send(.async(.observeEvent))
      }
    }
    .onChange(of: store.eventModel) { oldValue , newValue in
      store.send(.async(.updateEventModel(newValue)))
    }
    
    .sheet(item: $store.scope(state: \.destination?.makeEvent, action: \.destination.makeEvent)) { makeEventStore in
      MakeEventView(store: makeEventStore, completion: {
        store.send(.view(.closeMakeEventModal))
      })
      .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
      .presentationCornerRadius(20)
      .presentationDragIndicator(.hidden)
    }
  }
}

extension QrCodeView {
  
  @ViewBuilder
  fileprivate func generateQrImage() -> some View {
    VStack {
      
      Spacer()
        .frame(height: UIScreen.screenHeight * 0.2)
      
      if ((store.eventID?.isEmpty) != nil) {
        if let qrCodeImage = store.qrCodeImage {
          qrCodeImage
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 200, height: 200)
        } else {
          Image(asset: .appLogo)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
        }
      } else {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.gray800.opacity(0.4))
          .frame(width: 200, height: 200)
          .overlay {
            VStack {
              Spacer()
              Image(asset: .qrCode)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
              Spacer()
            }
            
          }
      }
    }
  }
  
  @ViewBuilder
  fileprivate func qrCodeReaderText() -> some View {
    if store.eventModel.isEmpty == false {
      VStack {
        Spacer()
          .frame(height: UIScreen.screenHeight * 0.1)
        
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
