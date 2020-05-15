//
//  ContentView.swift
//  ncmb.signinwithapple
//
//  Created by Atsushi on 2020/05/15.
//  Copyright © 2020 Atsushi. All rights reserved.
//

import UIKit
import SwiftUI
import AuthenticationServices

struct ContentView: View {
  var window: UIWindow?
  @State var appleSignInDelegates: SignInWithAppleDelegates! = nil

  var body: some View {
        SignInWithApple()
          .frame(width: 280, height: 60)
          .onTapGesture(perform: showAppleLogin)
  }

  private func showAppleLogin() {
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]

    performSignIn(using: [request])
  }

  private func performExistingAccountSetupFlows() {
    let requests = [
      ASAuthorizationAppleIDProvider().createRequest()
    ]
    performSignIn(using: requests)
  }

  private func performSignIn(using requests: [ASAuthorizationRequest]) {
    appleSignInDelegates = SignInWithAppleDelegates(window: window) { success in
      if success {
        // update UI
        print("success")
      } else {
        print("error")
        // show the user an error
      }
    }

    let controller = ASAuthorizationController(authorizationRequests: requests)
    controller.delegate = appleSignInDelegates
    controller.presentationContextProvider = appleSignInDelegates

    controller.performRequests()
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
