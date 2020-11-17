//
//  CreatePostViewController.swift
//  GorillaBook
//
//  Created by Alejandro Camacho on 17/11/20.
//

import UIKit

final class CreatePostViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var viewModel: CreatePostViewModel!
    
    weak var delegate: CreateEntryDelegate?
    
    override func viewDidLoad() {
        entryTextView.delegate = self
        viewModel =  CreatePostViewModel { [self] in
            characterCountLabel.text = viewModel.state.characterCountText
            imageView.image = viewModel.state.image
        }
        entryTextView.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareTapped))
    }
    @IBAction func addPhotoTapped(_ sender: Any) {
        showPhotos()
    }
    
    @objc func  shareTapped() {
        self.delegate?.didCreate(viewModel.state.newFeedEntry)
        self.navigationController?.popViewController(animated:true)
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

extension  CreatePostViewController: UIImagePickerControllerDelegate {
    func showPhotos(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        viewModel.imageAdded(info: info)
        self.dismiss(animated: true, completion: nil)
    }
}


struct CreateEntryState {
    var characterCountText: String = "0/150"
    var limitReached = false
    let characterLimit = 150
    var newFeedEntry: FeedEntry?
    var image: UIImage?
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
            updateFeedEntry(with: entryText)
        }
    }
    
    var callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    private func updateFeedEntry(with text: String) {
        var feedEntry = getOrCreateFeedEntry()
        feedEntry.body = text
        state.newFeedEntry = feedEntry
    }
    
    private func getOrCreateFeedEntry() -> FeedEntry {
        return state.newFeedEntry ?? FeedEntry(
            id: UUID().hashValue,
            firstName: "Alejandro",
            lastName: "Camacho",
            body: "",
            timestamp: String(Date().timeIntervalSince1970),
            image: nil
        )
    }
    
    func entryTextChanged(string:String) {
        entryText = string
    }
    
    func imageAdded(info:  [UIImagePickerController.InfoKey : Any]) {
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let localPath = documentDirectory?.appending(imgName)
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let data = image.pngData()! as NSData
            data.write(toFile: localPath!, atomically: true)
            let photoURL = URL.init(fileURLWithPath: localPath!)
            var feedEntry = getOrCreateFeedEntry()
            feedEntry.image = photoURL.absoluteString
            state.newFeedEntry = feedEntry
            state.image = image
        }
    }
    
    func characterCount(for string: String) -> Int {
        return string.count
    }
}
