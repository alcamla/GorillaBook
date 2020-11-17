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
    @IBOutlet weak var bodyLabel: UILabel!
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
        self.bodyLabel.text = viewModel.body
        if let photo = viewModel.photo {
            photoView.image = photo
            photoHeight.isActive = false
        } else {
            photoHeight.constant = 0
            photoHeight.isActive = true
        }
        
    }
}
