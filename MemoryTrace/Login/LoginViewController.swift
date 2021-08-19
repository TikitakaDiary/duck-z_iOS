//
//  LoginViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/12.
//

import UIKit
import AuthenticationServices
import Firebase
import GoogleSignIn
import KakaoSDKUser

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressKaKaoLogin(_ sender: UIButton) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    UserApi.shared.me() { [weak self] (user, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            guard let key = user?.id, let name = user?.kakaoAccount?.profile?.nickname else { return }
                            self?.login(name: name, snsKey: String(key), snsType: .kakao)
                        }
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    UserApi.shared.me() { [weak self] (user, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            guard let key = user?.id, let name = user?.kakaoAccount?.profile?.nickname else { return }
                            self?.login(name: name, snsKey: String(key), snsType: .kakao)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func didPressGoogleLogin(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { [weak self] user, error in
            guard error == nil else { return }

            guard let key = user?.userID, let name = user?.profile?.name else { return }
            self?.login(name: name, snsKey: key, snsType: .google)
        }
    }
    
    @IBAction func didPressAppleLogin(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func login(name: String, snsKey: String, snsType: SNSType) {
        
        guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") else { return }
        
        let loginInfo = Login(profileImg: nil, nickname: name, snsKey: snsKey, snsType: snsType, token: fcmToken)
        
        NetworkManager.shared.login(login: loginInfo) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let data = response.data else { return }
                let jwt = data.jwt
                let uid = data.uid
                UserDefaults.standard.set(jwt, forKey: "jwt")
                UserDefaults.standard.set(uid, forKey: "uid")
                self?.presentHomeController()
            case .failure(let error):
                self?.showToast(message: error.localizedDescription, position: .bottom)
            }
        }
    }
    
    private func presentHomeController() {
        guard let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as? HomeControllerRx else {return}
        let naviController = UINavigationController(rootViewController: homeVC)
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.rootViewController = naviController
    }
}

// MARK:- APPLE ID LOGIN
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // 연동 성공시 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {return}
        
        let key = credential.user
        let name = "\(credential.fullName?.familyName ?? "애플")\(credential.fullName?.givenName ?? " ")"
        
        login(name: name, snsKey: key, snsType: .apple)
    }
    
    // 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        self.showToast(message: error.localizedDescription, position: .bottom)
    }
}

