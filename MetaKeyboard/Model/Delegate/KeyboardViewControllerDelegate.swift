//
//  KeyboardViewControllerDelegate.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

public protocol KeyboardViewControllerDelegate {
	
	func keyboardViewController(_ keyboardViewController: KeyboardViewController, didChangeScore score: Double)
	
	func keyboardViewController(_ keyboardViewController: KeyboardViewController, didChangeTemperature temperature: Double)
	
}
