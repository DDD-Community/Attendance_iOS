//
//  ASAuthorizationControllerDelegateProxy.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

//import AuthenticationServices
//import Foundation
//
//import FirebaseAuth
//import RxSwift
//import RxCocoa
//
//class ASAuthorizationControllerDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>, DelegateProxyType, ASAuthorizationControllerDelegate {
//  nonisolated static func registerKnownImplementations() {
//    self.register { (controller) -> ASAuthorizationControllerDelegateProxy in
//      ASAuthorizationControllerDelegateProxy(parentObject: controller, delegateProxy: self)
//    }
//  }
//  
//  nonisolated static func currentDelegate(for object: ASAuthorizationController) -> ASAuthorizationControllerDelegate? {
//    return object.delegate
//  }
//  
//  nonisolated static func setCurrentDelegate(
//    _ delegate: ASAuthorizationControllerDelegate?,
//    to object: ASAuthorizationController
//  ) {
//    object.delegate = delegate
//  }
//}
//
//extension Reactive where Base: ASAuthorizationController {
//  var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
//    return ASAuthorizationControllerDelegateProxy.proxy(for: self.base)
//  }
//  
//  var didCompleteWithAuthorization: Observable<OAuthTokenResponse> {
//    delegate.methodInvoked(
//      #selector(
//        ASAuthorizationControllerDelegate
//          .authorizationController(controller:didCompleteWithAuthorization:)
//      )
//    )
//    .map { parameters in
//      guard let authorization = parameters[1] as? ASAuthorization,
//            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
//            let tokenData = credential.identityToken,
//            let idTokenString = String(data: tokenData, encoding: .utf8) else {
//        print("🔴 Failed to sign in with apple")
//        return OAuthTokenResponse(
//          accessToken: "",
//          refreshToken: "",
//          provider: .apple,
//          credential: nil
//        )
//      }
//      
//      let accessToken: String = .init(decoding: tokenData, as: UTF8.self)
//      let firebaseCredential = OAuthProvider.appleCredential(
//        withIDToken: idTokenString,
//        rawNonce: OAuthAppleService.currentNonce,
//        fullName: credential.fullName
//      )
//      return OAuthTokenResponse(
//        accessToken: accessToken,
//        refreshToken: "",
//        provider: .apple,
//        credential: firebaseCredential
//      )
//    }
//  }
//}
