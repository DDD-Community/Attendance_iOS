//
//  ImageAsset.swift
//  DDDDesignKit
//
//  Created by 서원지 on 7/13/24.
//

import Foundation

public enum ImageAsset: String {
  
  case managementProfile
  case appLogo
  case qrCode
  case eventGenerate
  case arrowBack
  case arrowBackWhite
  case plus
  case logo
  case pet
  case arrow_down
  case arrow_up
  case editEvent
  case user
  case info
  case closeGray
  
  // MARK: - 소셜로그인 버튼
  
  case appleLogin
  case googleLogin
  case google

  // MARK: - 회원가입
  
  case backButton
  case error
  case close
  case errorClose
  case disableSelectPart
  case activeSelectPart
  case acitveSelectTeam
  
  case empty
  
  // MARK: - 멤버 출석 현황
  
  case danger
  
  
  // MARK: - attandance
  case abesent_icons
  case late_icons
  case present_icons
  case thd_icons
  case stamp
  case late_stamp
  case present_stamp
  case profileBack
  
  // MARK: - QR
  case qrCheck
  case edit
  case editAttendance
  
  // MARK: - Vote
  case voteComplete = "vote_complete"

}
