//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ConfirmMnemonicViewModel {
    private let indices: [Int]
    private let aezeed: Aezeed
    private var currentIndex = 0
    
    let wordLabel = Observable<String>("")
    let checkCompleted = Observable(false)
    
    init(aezeed: Aezeed) {
        self.aezeed = aezeed
        
        var randomIndices = [Int]()
        while randomIndices.count < 3 {
            let randomNumber = Int(arc4random_uniform(UInt32(aezeed.wordList.count)))
            if !randomIndices.contains(randomNumber) {
                randomIndices.append(randomNumber)
            }
        }
        indices = randomIndices
        
        updateWord()
    }
    
    private func updateWord() {
        wordLabel.value = "Word #\(indices[currentIndex] + 1)"
    }
    
    func check(mnemonic: String) -> Bool {
        guard
            currentIndex < indices.count,
            mnemonic.lowercased() == aezeed.wordList[indices[currentIndex]]
            else { return false }

        currentIndex += 1
        if currentIndex < indices.count {
            updateWord()
        } else {
            checkCompleted.value = true
        }
        
        return true
    }
}
