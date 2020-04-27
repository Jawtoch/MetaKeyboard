//
//  Grid.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

public class Grid<T>: NSCopying {
	
	var matrix: [T]
	var rows: Int
	var columns: Int
	
	init(columns: Int, rows: Int, defaultValue: T) {
		self.rows = rows
		self.columns = columns
	
		self.matrix = Array(repeating: defaultValue, count: (rows * columns))
	}
	
	private init() {
		self.rows = 0
		self.columns = 0
		
		self.matrix = []
	}
	
	func indexIsValidForRow(column: Int, row: Int) -> Bool {
		return row >= 0 && row < rows && column >= 0 && column < columns
	}
	
	subscript(bigram: String) -> T {
		get {
			assert(bigram.count == 2, "Invalid bigram")
			let first = bigram[bigram.startIndex]
			let second = bigram[bigram.index(before: bigram.endIndex)]
			return self[Int(second.asciiValue! - 65),Int(first.asciiValue! - 65)]
		}
		set {
			assert(bigram.count == 2, "Invalid bigram")
			let first = bigram[bigram.startIndex]
			let second = bigram[bigram.index(before: bigram.endIndex)]
			self[Int(second.asciiValue! - 65),Int(first.asciiValue! - 65)] = newValue
		}
		
	}
	
	subscript(col: Int, row: Int) -> T {
		get{
			assert(indexIsValidForRow(column: col, row: row), "Index out of range")
			return matrix[Int(columns * row + col)]
		}
		set{
			assert(indexIsValidForRow(column: col, row: row), "Index out of range")
			matrix[(columns * row) + col] = newValue
		}
	}
	
	var description: String {
		var output = ""
		for row in 0 ..< self.rows {
			for column in 0 ..< self.columns {
				output += "\(self[column, row])"
				
				if column != self.columns - 1 {
					output += "\t,\t"
				}
			}
			output += "\n";
		}
		
		return output
	}
	
	public func copy(with zone: NSZone? = nil) -> Any {
		let grid = Grid<T>()
		grid.rows = self.rows
		grid.columns = self.columns
		grid.matrix = self.matrix
		return grid
	}
}
