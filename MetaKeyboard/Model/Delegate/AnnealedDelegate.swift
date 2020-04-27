//
//  AnnealedDelegate.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

public protocol AnnealedDelegate {

	func annealed(_ annealed: Any, didAcceptNewState state: Any, with energy: Double, temperature: Double)
	
	
}
