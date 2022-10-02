//
//  FrameworkViewModel.swift
//  AppleFrameworkWithMVVM
//
//  Created by Kay on 2022/10/02.
//

import Foundation
import Combine

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
