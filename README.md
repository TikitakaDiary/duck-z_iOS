# duck-z

### 소개

모바일 환경에서 친구, 연인, 가족과 일기를 공유할 수 있는 서비스

일기장 표지 꾸미기, 일기 작성 및 공유, 일기 확인등의 기능을 제공합니다.  
일기장 표지와 일기는 스티커 기능을 통해 더 다채롭게 꾸밀 수 있습니다.  

> Language : Swift 5.0  
> iOS Deployment Target : 13.0  
> App Store : https://apple.co/3hkktOM 

## 간편 로그인
카카오, 구글, 애플 계정으로 간편하게 로그인 할 수 있습니다.    
로그인 정보는 사용자 식별을 위해 최소한의 정보만 수집합니다. 

<img src="https://user-images.githubusercontent.com/31477658/124503989-93be7c00-de01-11eb-87e2-6b060c4fa9a5.png" width="25%" height="25%" >

<br>

## 일기장 목록
메인 화면에서 자신이 속한 일기장 목록을 확인할 수 있습니다.  
일기장은 일기 업데이트 순서대로 나열됩니다.   

<img src="https://user-images.githubusercontent.com/31477658/124503902-67a2fb00-de01-11eb-9715-4809d5a8ef3e.png" width="25%" height="25%" > 

<br>

## 일기장 생성 및 꾸미기
일기장 생성을 통해 일기장 표지 색상을 설정할 수 있고,    
스티커 기능을 통해 일기장을 꾸밀 수 있습니다.

<img src="https://user-images.githubusercontent.com/31477658/124503914-6ffb3600-de01-11eb-8294-0f6188d171ce.png" width="25%" height="25%" > <img src="https://user-images.githubusercontent.com/31477658/124503922-72f62680-de01-11eb-8b82-ddf131640e08.png" width="25%" height="25%" >

<br>

## 일기 목록
서버로부터 받은 일기 데이터는 알고리즘을 사용해 월 단위로 구분하고 섹션 별로 나누어 사용자에게 제공합니다.  
일기 목록은 폴라로이드 형식의 레이아웃과 그리드 형식의 레이아웃 두 가지를 제공함으로써  
사용자가 더 편리하게 일기 목록을 확인할 수 있도록 했습니다. 

<img src="https://user-images.githubusercontent.com/31477658/124503928-75588080-de01-11eb-9627-57f9a37a82d0.png" width="25%" height="25%" > <img src="https://user-images.githubusercontent.com/31477658/124503933-79849e00-de01-11eb-8717-071ca3a7f64e.png" width="25%" height="25%" >

<br>

## 일기 작성
폴라로이드 사진 영역에 앨범과 카메라를 통해 이미지를 넣거나 단색 배경을 추가할 수 있고,       
그 위에 스티커 기능을 통해 다채롭게 꾸밀 수 있습니다.

<img src="https://user-images.githubusercontent.com/31477658/124503944-80131580-de01-11eb-8d6a-4ba57f08adbd.png" width="25%" height="25%" > <img src="https://user-images.githubusercontent.com/31477658/124503967-8a351400-de01-11eb-8d24-695b36310934.png" width="25%" height="25%" >

<br>

## 일기 초대
초대 코드를 통해 일기장에 초대할 수 있고,   
멤버 관리를 통해 현재 일기장에 속해 있는 구성원을 파악할 수 있습니다.

<img src="https://user-images.githubusercontent.com/31477658/124504012-98833000-de01-11eb-8148-bd8f4636491c.png" width="25%" height="25%" >

<br>

## 푸시 알림
다음과 같은 상황에서 푸시 알림을 받을 수 있습니다.
1. 새로운 일기가 등록되었을 때
2. 새로운 멤버가 들어왔을 때
3. 자기 작성 차례가 되었을 때
 
알림을 누르면 해당 일기장으로 이동하며, 
일기장 생성 중이거나 일기 작성 중 일 때는    
기존 작성 상태 유지를 위해 이동하지 않습니다.

<img src="https://user-images.githubusercontent.com/31477658/130318278-e64c2c1f-ae1d-49c4-9a71-4670d3f146f9.png" width="50%" height="50%" >

<br> 

## 댓글 기능 
일기에 댓글을 작성할 수 있습니다. 

<img src="https://user-images.githubusercontent.com/31477658/133807096-2ce83f13-47bd-4591-b3e5-3d1d2336cc51.png" width="25%" height="25%" >

<br>

## 디자인 패턴

MVC 디자인 패턴으로 설계한 앱을 MVVM 디자인 패턴으로 리팩토링중에 있습니다.
비동기 처리와 데이터 바인딩은 RxSwift를 사용하고 있습니다. 

<img src="https://user-images.githubusercontent.com/31477658/133812741-2c733799-bb53-41b1-a8db-cbdf995cc74e.png" width="100%" height="100%" >

<br>

## 네트워크

통신의 경우 APIRequester와 Router로 분리하고 의존성 주입과 제네릭을 사용함으로써 코드 중복을 방지하고
유지 보수하기 쉽도록 개발했습니다.

```swift
import Foundation

enum Router {
    case createBook(bookCover: BookCover)
    case fetchBookInfo(bookID: Int)
    case fetchBookList(page: Int)
    case createDiary(writingContent: WritingContent)
    .....
    .....
    
    private var baseURL: String {
        return "....."
    }
    
    var url: String {
        return baseURL + path
    }
    
    private var path: String {
        switch self {
        case .createBook:
            return "/book"
    ......
    }
```


```swift
import Alamofire

struct APIRequester {
    typealias Completion<T> = (Result<T, AFError>) -> Void
    
    let router: Router

    init(with router: Router) {
        self.router = router
    }
    
    func getRequest<T: Codable> (completion: @escaping Completion<T>) {
        let request = AF.request(router.url, method: .get, headers: ["Authorization": token ?? "No value"]
        )

        request.responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    ....
}

```

<br>

## 중복 코드 및 중복 뷰 처리

여러 뷰 컨트롤러에서 중복되어 사용되는 뷰는 customview로 만들어 사용했고
같은 부모 클래스, 여러개의 객체가 생성되어 사용되는 경우라면 공통되는 코드부분은 extension으로 빼내어서 유지보수 하기 쉽도록 개발했습니다. 
이외에도 Property Wrapper를 사용해 중복 코드를 줄이고 유지 보수성을 높이려고 노력했습니다.

<img src="https://user-images.githubusercontent.com/31477658/133817270-11752429-fe60-47a9-8c1a-76d9f93b4f64.png" width="100%" height="100%" >
<img src="https://user-images.githubusercontent.com/31477658/133817486-6283d017-54e9-4827-81b2-656f3bb1a901.png" width="100%" height="100%" >

```swift
// Property Wrapper

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            let udValue = UserDefaults.standard.object(forKey: key) as? T
            switch (udValue as Any) {
            case Optional<Any>.some(let value):
                return value as! T
            case Optional<Any>.none:
                return defaultValue
            default:
                return udValue ?? defaultValue
            }
        }
        set {
            switch (newValue as Any) {
            case Optional<Any>.some(let value):
                UserDefaults.standard.set(value, forKey: key)
            case Optional<Any>.none:
                UserDefaults.standard.removeObject(forKey: key)
            default:
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}

final class UserManager {
    @UserDefault(key: "jwt", defaultValue: nil)
    static var jwt: String?
    
    @UserDefault(key: "signInDate", defaultValue: nil)
    static var signInDate: String?
    
    ...
}

```

<br>

## 다양한 예외 처리
네트워크 환경이 좋지 않을 때는 사용자가 여러 번 네트워크 api를 호출할 가능성이 있습니다. 이러한 여러 가지 상황들을 가정하며 예외 처리를 통해 api가 중복 호출되는 것을 방지했습니다. ex) 여러 번 버튼을 눌러 통신 api를 호출을 할 경우, paging이 적용된 컬렉션 뷰에서 여러 번 api를 호출할 경우 등..

텍스트를 저장할 때는 정규식을 사용해 space와 new line만 입력하는 것을 방지했습니다. 


<br>

## 앱의 성능 및 사용성 고려

알고리즘 개발시 시간복잡도를 고려하며 개발하고 있고, 이미지 캐싱, 이미지 리사이즈, 페이징, pull to refresh 등 다양한 기술을 적용함으로써 앱의 성능과 사용성을 고려했습니다.
