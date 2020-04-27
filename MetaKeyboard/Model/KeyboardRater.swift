//
//  KeyboardRater.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

public class KeyboardRater {
	
	private let frequencies: BigramFrequencies
	
	public init(frequencies: BigramFrequencies) {
		self.frequencies = frequencies
	}
	
	public func rateKeyboard(_ keyboard: Keyboard) -> Double {
		
		var score: Double = 0.0
		
		for source in keyboard.alphabet {
			var set = keyboard.alphabet
			
			while !set.isEmpty {
				let target = set.removeLast()
				if target != source {
					if let distance = keyboard.distanceFrom(source, to: target) {
						score += distance * self.frequencies.frequencyForBigram(source, target)
					}
					
				}
				
			}
			
		}
		
		return score
	}
	
}
