//
//  IntervalTableViewCell.swift
//  TIMER
//
//  Created by Aditya Maroo on 13/12/24.
//

import UIKit

class IntervalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkBoxImage:UIButton!
    @IBOutlet weak var intervalName: UILabel!
    @IBOutlet weak var intervalDuration: UILabel!
    @IBOutlet weak var intervalCount: UILabel!
    @IBOutlet weak var rectangualarView: UIView!
    @IBOutlet weak var movableImage: UIImageView!
    static var identifier: String{
        return String(describing: self)
    }
    static func nib()-> UINib{
        return UINib(nibName: IntervalTableViewCell.identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
