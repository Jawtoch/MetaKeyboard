//
//  BigramParser.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

public class BigramParser {
	
	public typealias Number = Double
	
	/// Le séparateur entre deux valeurs
	public var separator: String = "\t"
	
	/// Le séparateur entre deux lines
	public var lineSeparator: String = "\n"
	
	/// Spécifie si la première colonne contient les noms des lignes
	public var rowNames: Bool = true
	
	/// Spécifie si la première ligne contient les noms des colonnes
	public var columnNames: Bool = true
	
	public var matrix: Grid<Number>?
	
	public func parseFile(_ file: URL, size: Int = 26) throws {
		let handle = try FileHandle(forReadingFrom: file)
		let fileData = handle.readDataToEndOfFile()
		
		self.matrix = Grid(columns: size, rows: size, defaultValue: 0.0)
		try self.parseData(fileData, on: self.matrix!)
	}
	
	private func parseData(_ data: Data, on grid: Grid<Number>) throws {
		guard let fileContent = String(data: data, encoding: .utf8) else {
			return
		}
		
		if fileContent.isEmpty {
			throw BigramParserError.invalidFile
		}
		
		try self.parseContent(fileContent, on: grid)
	}
	
	private func parseContent(_ content: String, on grid: Grid<Number>) throws {
		var lines = content.components(separatedBy: self.lineSeparator)
		
		if self.columnNames {
			lines.removeFirst()
		}
		
		if lines.isEmpty {
			throw BigramParserError.invalidFile
		}
		
		for (index, line) in lines.enumerated() {
			try self.parseLine(index, content: line, on: grid)
		}
		
	}

	private func parseLine(_ line: Int, content: String, on grid: Grid<Number>) throws {
		var values = content.components(separatedBy: self.separator)
		
		if self.rowNames {
			values.removeFirst()
		}
		
		if values.isEmpty {
			throw BigramParserError.invalidFile
		}

		for (index, value) in values.enumerated() {
			guard let intValue = Number(value) else {
				throw BigramParserError.invalidValue("""
					Valeur invalide: ligne \(line), colonne \(index): '\(value)'
					""")
			}
			
			grid[index, line] = intValue
		}

	}
}

public enum BigramParserError: Error {
	case invalidValue(String)
	case invalidFile
}
