//
//  KeyCollectionViewCell.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 23/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import UIKit

class KeyCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var keyLabel: UILabel!
	
	var key: String = "" {
		didSet {
			self.keyLabel.text = key
		}
		
	}
	
	override init(frame: CGRect) {
		self.key = "·"
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		if let keyText = coder.decodeObject(forKey: "keyText") as? String {
			self.key = keyText
		}
		
		super.init(coder: coder)
	}
	
	override func encode(with coder: NSCoder) {
		coder.encode(self.key, forKey: "keyText")
		super.encode(with: coder)
	}
	
	override func prepareForReuse() {
		if #available(iOS 13.0, *) {
			self.backgroundColor = .systemGray4
		} else {
			// Fallback on earlier versions
			self.backgroundColor = .lightGray
		}
	}
	
}
