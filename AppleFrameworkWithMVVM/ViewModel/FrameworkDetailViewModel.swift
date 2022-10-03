//
//  FrameworkDetailViewModel.swift
//  AppleFrameworkWithMVVM
//
//  Created by Kay on 2022/10/02.
//

import Foundation
import Combine

final class FrameworkDetailViewModel {
    
    init(framework: AppleFramework) {
        self.selectedApp = CurrentValueSubject(framework)
    }
    // Data -> Output
    var selectedApp: CurrentValueSubject<AppleFramework, Never>
    
    // User Action -> Input
    var buttonTapped = PassthroughSubject<AppleFramework, Never>()
    
    func learnMoreButtonTapped() {
        buttonTapped.send(selectedApp.value)
    }
}
