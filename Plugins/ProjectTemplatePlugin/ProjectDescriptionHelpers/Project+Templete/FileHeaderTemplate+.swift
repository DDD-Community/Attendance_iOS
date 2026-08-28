//
//  FileHeaderTemplate+.swift
//  ProjectDescriptionHelpers
//
//  Xcode 파일 헤더(IDETemplateMacros). 새 파일 생성 시 자동 삽입된다.
//  ___FILENAME___/___PACKAGENAME___/___FULLUSERNAME___/___DATE___/___YEAR___ 는 Xcode가 채운다.
//

import ProjectDescription

public extension FileHeaderTemplate {
  /// 프로젝트 공통 파일 헤더 (저작권 포함)
  static var `default`: FileHeaderTemplate {
    """
    //
    //  ___FILENAME___
    //  ___PACKAGENAME___
    //
    //  Created by ___FULLUSERNAME___ on ___DATE___.
    //  Copyright © ___YEAR___ DDD. All rights reserved.
    //
    """
  }
}
