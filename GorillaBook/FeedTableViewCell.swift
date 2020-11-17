//
//  FeedTableViewCell.swift
//  GorillaBook
//
//  Created by Alejandro Camacho on 16/11/20.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var photoHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}


extension FeedTableViewCell {
    func bind(with viewModel: FeedEntryViewModel) {
        self.nameLabel.text = viewModel.name
        self.dateLabel.text = viewModel.date
        self.bodyTextView.text = viewModel.body
        if let imageName = viewModel.image {
            photoView.setImage(from: imageName)
        } else {
            photoHeight.constant = 0
            photoHeight.isActive = true
            setNeedsLayout()
        }
        
    }
}


extension UIImageView {
    func setImage(from url: String?) {
        guard let urlString = url, let validUrl = URL(string: urlString) else {
            self.image = UIImage()
            return
        }
        
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: validUrl) else {
                self.image = UIImage()
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
                self.setNeedsLayout()
            }
        }
    }
}
