//
//  BigramFrequencies.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

public class BigramFrequencies {
	
	private var grid: Grid<BigramParser.Number>
	
	public init(grid: Grid<BigramParser.Number>) {
		self.grid = grid
	}
	
	public func normalize() {
		var minV: BigramParser.Number = .infinity
		var maxV: BigramParser.Number = .leastNormalMagnitude
		
		for column in 0 ..< self.grid.columns {
			for row in 0 ..< self.grid.rows {
				let value = self.grid[column, row]
				minV = min(minV, value)
				maxV = max(maxV, value)
			}
			
		}
		
		for column in 0 ..< self.grid.columns {
			for row in 0 ..< self.grid.rows {
				let value = self.grid[column, row]
				self.grid[column, row] = (value - minV) / (maxV - minV)
			}
			
		}
		
	}
	
	public func frequencyForBigram(_ lhs: Character, _ rhs: Character) -> BigramParser.Number {
		assert(lhs.isASCII, "Character needs to be ASCII")
		assert(rhs.isASCII, "Character needs to be ASCII")
		
		let startingValue = Int(("A" as UnicodeScalar).value)
		
		return self.grid[Int(rhs.asciiValue!) - startingValue, Int(lhs.asciiValue!) - startingValue]
	}
	
}
