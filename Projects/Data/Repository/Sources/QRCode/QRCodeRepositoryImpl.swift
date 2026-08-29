//
//  QRCodeRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

import DomainInterface
import Model
import Service
import Entity

@preconcurrency import AsyncMoya

@Observable
final public class QRCodeRepositoryImpl: QRCodeInterface {
  
  private let provider: MoyaProvider<QRService>
  
  public init(
    provider: MoyaProvider<QRService> = MoyaProvider<QRService>.authorized
  ) {
    self.provider = provider
  }
  
  // MARK: - QRCode String 생성
  
  public func createQRCode(userID: Int) async throws -> String {
    let response: CreateQRCodeResponseDTO = try await provider.request(.createQRCode(userID: userID))
    return response.qrBase64
  }
  
  // MARK: - QRCode Image 생성
  
  public func generateQRCode(from string: String) async -> SwiftUI.Image? {
    if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters),
       let uiImage = UIImage(data: data) {
      return Image(uiImage: uiImage)
    }
    return nil
  }
  
  public func qrValidateCheck(from code: String) async throws -> Entity.QRValidateEntity {
    let response = try await provider.requestResponse(.qrAttendanceCheck(qrCode: code))
    let decoder = JSONDecoder()
    
    if (200...299).contains(response.statusCode) {
      if response.data.isEmpty {
        return QRValidateEntity(isSuccess: true)
      }
      if let successDTO = try? decoder.decode(QRValidateDTO.self, from: response.data) {
        return successDTO.toDomain(isSuccess: true)
      }
      return QRValidateEntity(isSuccess: true)
    }
    
    // 400+ 에러는 exception으로 throw
    if let errorDTO = try? decoder.decode(QRValidateDTO.self, from: response.data) {
      // 서버에서 온 상세 메시지 우선 사용
      let userMessage = errorDTO.message ?? "알 수 없는 오류가 발생했습니다"
      
      switch response.statusCode {
      case 400...499:
        // 클라이언트 오류 - 서버 메시지를 사용자에게 표시
        throw AttendanceError.unknown(userMessage)
      case 500...599:
        // 서버 오류
        throw AttendanceError.serverError(response.statusCode)
      default:
        throw AttendanceError.unknown(userMessage)
      }
    }
    
    // JSON 디코딩 실패 시
    let rawMessage = String(data: response.data, encoding: .utf8) ?? "디코딩 실패"
    throw AttendanceError.decodingError("응답 파싱 실패: \(rawMessage)")
  }
}
