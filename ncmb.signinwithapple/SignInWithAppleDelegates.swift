//
//  SignInWithAppleDelegates.swift
//  ncmb.signinwithapple
//
//  Created by Atsushi on 2020/05/15.
//  Copyright © 2020 Atsushi. All rights reserved.
//

import UIKit
import AuthenticationServices
import Contacts
import NCMB

class SignInWithAppleDelegates: NSObject {
  private let signInSucceeded: (Bool) -> Void
  private weak var window: UIWindow!
  
  init(window: UIWindow?, onSignedIn: @escaping (Bool) -> Void) {
    self.window = window
    self.signInSucceeded = onSignedIn
  }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {

  private func signInWithUserAndPassword(credential: ASPasswordCredential) {
    self.signInSucceeded(true)
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let appleIDCredential as ASAuthorizationAppleIDCredential:
        // 認証情報による認証の場合、mobile backendに会員登録・認証を行う準備します
        let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
        //NCMBAppleParametersで発行された認証情報を指定します
        let appleParam = NCMBAppleParameters(id: appleIDCredential.user, accessToken: authorizationCode)
        let user = NCMBUser()
        
        if (appleIDCredential.fullName?.familyName != nil && appleIDCredential.fullName?.givenName != nil) {
            let familyName = appleIDCredential.fullName?.familyName ?? ""
            let givenName = appleIDCredential.fullName?.givenName ?? ""
            user["fullName"] = "\(givenName) \(familyName)"
        }
        user["email"] = appleIDCredential.email
        // mobile backendに会員登録・認証を行います
        user.signUpWithAppleToken(appleParameters: appleParam, callback: { result in
        switch result {
            case .success:
                print("会員認証完了しました。")
            case let .failure(error):
                print("エラー: \(error)")
            }})
      break
      
    case let passwordCredential as ASPasswordCredential:
      signInWithUserAndPassword(credential: passwordCredential)

      break
      
    default:
      break
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
  }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.window
  }
}
