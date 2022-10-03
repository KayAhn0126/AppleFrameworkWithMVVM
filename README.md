# AppleFrameworkWithMVVM

## 🍎 작동화면
| 작동 화면 |
|:---------:|
| ![](https://i.imgur.com/fYGoumP.gif)  |

## 🍎 구성
- Model
    - FrameworkData.swift
- View
    - FrameworkViewController.swift
    - FrameworkDetailViewController.swift
    - FrameworkCollectionViewCell.swift
    - Main.storyboard
    - Detail.storyboard
- ViewModel
    - FrameworkViewModel
    - FrameworkDetailViewModel

## 🍎 왜 기존 MVC에서 MVVM으로 바뀌었나?
- View Controller에서 처리하는 양이 많아지고 그에 따라 너무 방대해져 Model의 데이터를 받아 처리하는 로직과 UI만을 처리하는 로직이 따로있는것이 추후 유지보수 관점에서 보았을때 좋을것이라 판단.
- FrameworkViewController내 
    - Model 데이터를 받아 특정 로직을 실행하는 코드를 **FrameworkViewModel로 이전**.
    - Model 데이터와 연관없는 **UI 관련 로직은 그대로**.
- FrameworkDetailViewController내
    - Model 데이터를 받아 특정 로직을 실행하는 코드를 **FrameworkDetailViewModel로 이전**.
    - Model 데이터와 연관없는 **UI 관련 로직은 그대로**.

## 🍎 기존 AppleFrameworkWithModalAndCombine 프로젝트와 다른점.
- 기존 VC에서 처리하는 로직을 줄이기 위해 Model을 사용하는 코드(퍼블리셔)를 ViewModel로 이전.
```swift
class FrameworkViewModel {
    
    init(frameworkListPublisher: [AppleFramework], selectedItem: AppleFramework? = nil) {
        self.frameworkListPublisher = CurrentValueSubject(frameworkListPublisher)
        self.selectedItem = CurrentValueSubject(selectedItem)
    }
    
    // Data => Output
    var frameworkListPublisher: CurrentValueSubject<[AppleFramework], Never> // 모델을 받아와 첫화면에 보여지는 아이템들을 가지고 있는 퍼블리셔
    let selectedItem: CurrentValueSubject<AppleFramework?, Never> // 아이템이 선택되면 해당 아이템을 가지고 있는 퍼블리셔
    
    // User Action => Input
    func didSelect(at indexPath: IndexPath) {
        let item = frameworkListPublisher.value[indexPath.item]
        selectedItem.send(item)
    }
}
```
- 아래의 코드처럼 원래 로직이 구현 되어 있었던 클래스에 viewModel 객체를 선언 후 사용.

```swift
class FrameworkViewController: UIViewController {
    
    //... (중략) ...
    var viewModel: FrameworkViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FrameworkViewModel(frameworkListPublisher: AppleFramework.list)
        //... (중략) ...
    }
    
    private func bind() {
        // input -> 사용자 입력을 받아서 처리
        // - 아이템 선택 되었을때 처리
        viewModel.selectedItem
            //... (중략) ...
            }.store(in: &subscriptions)
        
        // output -> data, state에 따라서 UI 업데이트
        // - items가 세팅 되었을때 collectionView 업데이트
        
        viewModel.frameworkListPublisher
            //... (중략) ...
            }.store(in: &subscriptions)
    }

    //... (중략) ...

extension FrameworkViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
    }
}
```

## 🍎 구현하면서 생각한 점
**Q**.퍼블리셔를 sink로 다운스트림 후, subscription 또한 마찬가지로 viewModel에서 관리하면 안될까?
- 예제코드
```swift
private func bind() {
        // input -> 사용자 입력
        viewModel.buttonTapped
            .receive(on: RunLoop.main)
            .compactMap { URL(string: $0.urlString)}
            .sink { [unowned self] url in
                let safari = SFSafariViewController(url: url)
                self.present(safari, animated: true)
            }.store(in: &subscriptions)
        
        // output -> 데이터 변경으로 인한 UI업데이트
        viewModel.selectedApp
            .receive(on: RunLoop.main)
            .sink { [unowned self] selectedAppData in
                self.updateUI(selectedAppData)
            }.store(in: &subscriptions)
    }
```
**A**. 구독을 하는 행위는 사실 해당 View Controller에서 하고 있으므로 굳이 viewModel까지 가서 store하지 않아도 될것같다.
