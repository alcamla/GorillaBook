//
//  CreatePostViewController.swift
//  GorillaBook
//
//  Created by Alejandro Camacho on 17/11/20.
//

import UIKit

final class CreatePostViewController: UIViewController {
    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    var viewModel: CreatePostViewModel!
    
    weak var delegate: CreateEntryDelegate?
    
    override func viewDidLoad() {
        entryTextView.delegate = self
        viewModel =  CreatePostViewModel { [self] in
            characterCountLabel.text = viewModel.state.characterCountText
        }
        entryTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.didCreate(viewModel.state.newFeedEntry)
    }
    
}

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.entryTextChanged(string: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= viewModel.state.characterLimit
    }
}

struct CreateEntryState {
    var characterCountText: String = "0/150"
    var limitReached = false
    let characterLimit = 150
    var newFeedEntry: FeedEntry?
}

final class CreatePostViewModel {
    
    var state: CreateEntryState = CreateEntryState() {
        didSet {
            callback()
        }
    }

    private var entryText: String = "" {
        didSet {
            let count = characterCount(for: entryText)
            if count >= state.characterLimit {
                state.limitReached = true
            }
            state.characterCountText = "\(count)/150"
        }
    }
    
    var callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    func entryTextChanged(string:String) {
        entryText = string
        
    }
    
    func characterCount(for string: String) -> Int {
        return string.count
    }
}
