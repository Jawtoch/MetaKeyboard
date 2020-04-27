//
//  ViewController+UIAlertController.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	
	func error(message: String, completion: (() -> Void)? = nil) {
		self.showAlert(title: "Une erreur est survenue", message: message, completion: completion)
	}
	
	func info(message: String, completion: (() -> Void)? = nil) {
		self.showAlert(title: "Information", message: message, completion: completion)
	}
	
	func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default))
		
		self.present(alert, animated: true, completion: completion)
	}
	
}
