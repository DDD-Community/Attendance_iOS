//
//  QRScannerView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

import DesignSystem

import AsyncMoya
import ComposableArchitecture
import Model

struct QRScannerView: View {
  var onClose: (() -> Void)?
  var backAction: () -> Void = {}
  @Bindable var store: StoreOf<QRCode>
  
  init(
    store: StoreOf<QRCode>,
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
      qrScanningView()
      
      scanedTextViewWithBackGround()
      
      // 3. 왼쪽 상단 닫기 버튼
      navigationBar()
    }
    .onChange(of: store.scannedText) { oldValue ,newValue in
      // 스캔된 텍스트가 업데이트되면, 2초 후에 재스캔을 위해 상태 재활성화
      if !newValue.isEmpty {
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
          store.scannedText = ""
          store.isScanning = true
          store.isPresent = false
        }
      }
    }
    .onChange(of: store.qrCheckModel?.data.status) { oldValue, newValue in
      switch newValue {
      case .present, .late, .absent:
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          backAction()
        }
      default:
        break
      }
    }
  }
}

extension QRScannerView {
  
  @ViewBuilder
  fileprivate func navigationBar() -> some View {
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
  
  @ViewBuilder
  fileprivate func qrScanningView() -> some View {
    QRScannerRepresentable(
      shouldStartScanning: $store.isScanning,
      scannedText: $store.scannedText,
      scannAction: {
        store.send(.async(.qrCodeValidate))
      },
      dataToScanFor: [.barcode(symbologies: [.qr])]
    )
    .ignoresSafeArea()
  }
  
  @ViewBuilder
  fileprivate func scanedTextViewWithBackGround() -> some View {
    let attendanceStatus =  store.qrCheckModel?.data.status
    GeometryReader { proxy in
      let width = proxy.size.width
      let height = proxy.size.height
      // 화면 중앙에 scannerSize 크기의 네모 영역을 배치하기 위한 좌표 계산
      let rectX = (width - store.scannerSize) / 2
      let rectY = (height - store.scannerSize) / 2
      
      // (A) 반투명 오버레이 + 중앙 네모 영역은 투명하게
      Color.basicBlack.opacity(0.5)
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
      scanText(attendanceType: attendanceStatus)
        .position(x: width / 2, y: rectY - 30)
      // (C) 중앙 테두리 (네모 영역 강조)
      RoundedRectangle(cornerRadius: 12)
        .stroke(store.isPresent ? .statusFocus : .clear , lineWidth: 2)
        .frame(width: store.scannerSize, height: store.scannerSize)
        .position(x: rectX + store.scannerSize / 2,
                  y: rectY + store.scannerSize / 2)
    }
  }
  
  @ViewBuilder
  fileprivate func scanText(
    attendanceType: AttendanceType?,
  ) -> some View {
    switch attendanceType {
    case .present:
      HStack(spacing: .zero){
        Spacer()
        Image(asset: .qrCheck)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
        
        Spacer()
          .frame(width: 4)
        
        Text("출석이 완료됐어요!")
          .pretendardCustomFont(textStyle: .body1NormalMedium)
          .foregroundColor(.staticWhite)


        Spacer()
      }
    case .late:
      HStack(spacing: .zero){
        Spacer()
        Image(asset: .qrCheck)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
        
        Spacer()
          .frame(width: 4)
        
        Text("10분 초과로 지각이에요")
          .pretendardCustomFont(textStyle: .body1NormalMedium)
          .foregroundColor(.staticWhite)
          .pretendardCustomFont(textStyle: .body1NormalMedium)
        
        
        Spacer()
      }
    case .absent:
      HStack(spacing: .zero){
        Spacer()
        Image(asset: .qrCheck)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
        
        Spacer()
          .frame(width: 4)
        
        Text("30분 초과로 결석이에요")
          .pretendardCustomFont(textStyle: .body1NormalMedium)
          .foregroundColor(.staticWhite)
        
        Spacer()
      }
    default:
      Text(store.isUseQRCode ? "이미 사용된 QR 코드입니다.":  "QR 코드를 스캔해 주세요")
        .pretendardCustomFont(textStyle: .body1NormalMedium)
        .foregroundColor(.staticWhite)
    }
  }
  
}
