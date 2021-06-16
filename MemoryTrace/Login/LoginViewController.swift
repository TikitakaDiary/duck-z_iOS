//
//  LoginViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/12.
//

import UIKit
import AuthenticationServices
import GoogleSignIn
import KakaoSDKUser

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @IBAction func didPressKaKaoLogin(_ sender: UIButton) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
//                    self.showToast(message: error.localizedDescription, position: .bottom)
                }
                else {
                }
            }
            
            UserApi.shared.me() { [weak self] (user, error) in
                if let error = error {
                    print(error)
//                    self?.showToast(message: error.localizedDescription, position: .bottom)
                }
                else {
                    guard let key = user?.id, let name = user?.kakaoAccount?.profile?.nickname else { return }
                    
                    self?.login(loginInfo: Login(profileImg: nil, nickname: name, snsKey: String(key), snsType: .kakao))
                }
            }
        }
    }
    
    @IBAction func didPressGoogleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func didPressAppleLogin(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func login(loginInfo: Login) {
        NetworkManager.shared.login(login: loginInfo) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let data = response.data else { return }
                let jwt = data.jwt
                let uid = data.uid
           
                self?.presentHomeController()
            case .failure(let error):
                self?.showToast(message: error.localizedDescription, position: .bottom)
            }
        }
    }
    
    private func presentHomeController() {
        guard let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as? HomeController else {return}
        let naviController = UINavigationController(rootViewController: homeVC)
        naviController.modalPresentationStyle = .fullScreen
        self.present(naviController, animated: false, completion: nil)
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
        
        login(loginInfo: Login(profileImg: nil, nickname: name, snsKey: key, snsType: .apple))
    }
    
    // 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        self.showToast(message: error.localizedDescription, position: .bottom)
    }
}

// MARK:- GOOGLE ID LOGIN
extension LoginViewController: GIDSignInDelegate {
    // 연동을 시도 했을때 불러오는 메소드
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
//                self.showToast(message: error.localizedDescription, position: .bottom)
            }
            return
        }
        
        // 사용자 정보 가져오기
        guard let key = user.userID, let name = user.profile.name else { return }
        login(loginInfo: Login(profileImg: nil, nickname: name, snsKey: key, snsType: .google))
    }
    
    // 구글 로그인 연동 해제
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Disconnect")
    }
}
