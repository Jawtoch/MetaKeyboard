//
//  Keyboard.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

extension IndexPath {
	
	init(column: Int, row: Int) {
		self.init(row: column, section: row)
	}
	
}

public class Keyboard {
	
	/// Le nombre de lignes
	public let rows: Int
	
	/// Le nombre de colonnes
	public let columns: Int
	
	/// La grille du clavier
	private let grid: Grid<Character>
	
	public init(rows: Int, columns: Int) {
		self.rows = rows
		self.columns = columns
		
		self.grid = Grid(columns: self.columns, rows: self.rows, defaultValue: Character(" "))
	}
	
	private init(rows: Int, columns: Int, grid: Grid<Character>) {
		self.rows = rows
		self.columns = columns
		
		self.grid = grid
	}
	
	/// L'index du caractère souhaité
	public func indexForCharacter(_ character: Character) -> IndexPath? {
		var column = 0
		var row = 0
		var currentChar: Character?
		
		while column < self.columns && currentChar != character {
			row = 0
			while row < self.rows && currentChar != character {
				currentChar = self.grid[column, row]
				row += 1
			}
			
			column += 1
		}
		
		if currentChar == character {
			return IndexPath(column: column - 1, row: row - 1)
		}

		return nil
	}
	
	/// Le caractère à l'index souhaité
	public func characterForItem(at indexPath: IndexPath) -> Character {
		return self.grid[indexPath.row, indexPath.section]
	}
	
	/// Place un caractère à un index
	public func setCharacter(_ character: Character, at indexPath: IndexPath) {
		self.grid[indexPath.row, indexPath.section] = character
	}
	
	/// Mélange le clavier de façon aléatoire
	public func shuffle() {
		let characterSet = self.randomCharSet
		let indexSet = self.randomIndexSet
		
		for i in 0 ..< characterSet.count {
			self.setCharacter(characterSet[i], at: indexSet[i])
		}
	}
	
	/// Déplace une lettre sur le clavier
	public func smallShuffle() -> Keyboard? {
		// On clone le clavier actuel
		let newGrid = self.grid.copy() as! Grid<Character>
		let newKeyboard = Keyboard(rows: self.rows, columns: self.columns, grid: newGrid)
		
		// On prend un caractère au hasard
		guard let randomChar = self.alphabet.randomElement() else {
			return nil
		}
		
		// On cherche son index
		guard let indexOfRandomChar = self.indexForCharacter(randomChar) else {
			return nil
		}
		
		// On supprime ce caractère du clavier
		newKeyboard.setCharacter(Character(" "), at: indexOfRandomChar)
		
		// On cherche un index disponible
		var indexes = self.randomIndexSet
		var emptyChar: Character?
		var index: IndexPath?
		
		// Tant qu'il nous reste des index, et que le caractère à l'index n'est pas vide (ie. " ")
		while !indexes.isEmpty && emptyChar != Character(" ") {
			index = indexes.removeFirst()
			emptyChar = self.characterForItem(at: index!)
		}
		
		if index == nil {
			return nil
		}
		
		// On place le caractère au nouvel index
		newKeyboard.setCharacter(randomChar, at: index!)
		
		return newKeyboard
	}
	
	/// La distance entre deux caractères du clavier
	public func distanceFrom(_ lhs: Character, to rhs: Character) -> Double? {
		guard let lhsIndex = self.indexForCharacter(lhs) else {
			return nil
		}
		
		guard let rhsIndex = self.indexForCharacter(rhs) else {
			return nil
		}
		
		return (pow(Double(lhsIndex.row - rhsIndex.row), 2) + pow(Double(lhsIndex.section - rhsIndex.section), 2)).squareRoot()
	}
	
	/// Un tableau avec les caractères de l'alphabet
	public var alphabet: [Character] {
		var letters: Array<Character> = []
		
		let startingValue = Int(("A" as UnicodeScalar).value) // 65
		for i in 0 ..< 26 {
			letters.append(Character(UnicodeScalar(i + startingValue)!))
		}
		
		return letters
	}
	
	/// Un tableau avec les caractères de l'alphabet, dans un ordre aléatoire
	private var randomCharSet: [Character] {
		var letters = self.alphabet
		letters.shuffle()
		
		return letters
	}
	
	/// Un tableau avec les index des touches du clavier
	public var indexes: [IndexPath] {
		var set: [IndexPath] = []
		
		for column in 0 ..< self.columns {
			for row in 0 ..< self.rows {
				set.append(IndexPath(column: column, row: row))
			}
			
		}
		
		return set
	}
	
	/// Un tableau avec les index des touches du clavier, dans un ordre aléatoire
	private var randomIndexSet: [IndexPath] {
		var set = self.indexes
		
		set.shuffle()
		
		return set
	}
}
