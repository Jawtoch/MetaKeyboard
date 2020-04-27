//
//  KeyboardCollectionViewLayout.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 23/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import UIKit

/// Présente les cellules sous forme d'un clavier.
/// Chaque section représente une ligne.
/// Le contenu de chaque ligne est centré.
/// Le clavier est centré dans la collectionView
class KeyboardCollectionViewLayout: UICollectionViewLayout {

	// MARK: - CollectionView
	/// La hauteur de la collectionView
	private var collectionViewHeight: CGFloat {
		guard let collectionView = self.collectionView else {
			return 0
		}
		
		return collectionView.frame.inset(by: collectionView.contentInset).height
	}
	
	/// La largeur de la collectionView
	private var collectionViewWidth: CGFloat {
		guard let collectionView = self.collectionView else {
			return 0
		}
		
		return collectionView.frame.inset(by: collectionView.contentInset).width
	}
	
	/// Parle de lui même ?
	private var collectionViewEdgeInsets: UIEdgeInsets {
		return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
	
	/// La surface de la collectionView
	override var collectionViewContentSize: CGSize {
		return CGSize(width: self.keyboardWidth, height: self.keyboardHeight)
	}
	
	/// Nombre de sections dans la collectionView
	private var numberOfSections: Int {
		guard let numberOfSections = self.collectionView?.numberOfSections else {
			return .zero
		}
		
		return numberOfSections
	}
	
	// Nombre d'items dans une section donnée
	private func numberOfItems(inSection section: Int) -> Int {
		guard let collectionView = self.collectionView else {
			return .zero
		}
		
		return collectionView.numberOfItems(inSection: section)
	}
	
	// MARK: - Keyboard
	/// L'origin du clavier, centré dans la collection
	private var keyboardOrigin: CGPoint {
		let y = (self.collectionViewHeight - self.keyboardHeight) / 2
		let x = (self.collectionViewWidth - self.keyboardWidth) / 2
		
		return CGPoint(x: x, y: y)
	}
	
	/// Largeur du clavier
	private var keyboardWidth: CGFloat {
		let totalKeyboardWidth = self.cellSize.width * CGFloat(self.maximumCellsInRow)
		
		return totalKeyboardWidth
	}
	
	/// Hauteur du clavier
	private var keyboardHeight: CGFloat {
		let totalKeyboardHeight = self.cellSize.height * CGFloat(self.numberOfSections)
		
		return totalKeyboardHeight
	}
	
	// MARK: - Cellules
	/// Nombre maximal de cellules sur une ligne
	private var maximumCellsInRow: Int {
		guard let collectionView = self.collectionView else {
			return .zero
		}
		
		var maximumCellsInRow = 0
		for section in 0 ..< self.numberOfSections {
			let numberOfCellsInCurrentRow = collectionView.numberOfItems(inSection: section)
			maximumCellsInRow = max(maximumCellsInRow, numberOfCellsInCurrentRow)
		}
		
		return maximumCellsInRow
	}
	
	/// Taille maximale d'une cellule dans le clavier, tout en respectant l'aspect ratio
	private var cellSize: CGSize {
		// On cherche d'abord la hauteur maximale des cellules.
		// Il faut donc regarder le nombre de lignes (ie. de sections), et diviser la hauteur totale par le nombre de lignes
		let numberOfSections = self.numberOfSections
		let availableHeight = self.collectionViewHeight
		
		let maxCellHeight = availableHeight / CGFloat(numberOfSections)
		
		let availableWidth = self.collectionViewWidth
		let maxCellWidth = availableWidth / CGFloat(self.maximumCellsInRow)
		
		let cellWidth = min(maxCellHeight * self.cellAspectRatio, maxCellWidth)
		
		return CGSize(width: cellWidth, height: cellWidth / self.cellAspectRatio)
	}
	
	/// Le ratio largeur / hauteur de chaque cellule
	private var cellAspectRatio: CGFloat {
		return 1
	}
	
	// MARK: - Cache
	/// Cache les attributs de layout pour chaque indexPath
	private var cache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
	
	// Prepare les éléments
	override func prepare() {
		super.prepare()
		
		self.cache.removeAll()
		let size = self.cellSize
		
		for section in 0 ..< self.numberOfSections {
			for row in 0 ..< self.numberOfItems(inSection: section) {
				let indexPath = IndexPath(row: row, section: section)
				let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				prepareElement(of: size, with: attribute)
			}
			
		}
		
	}
	
	// Invalide le layout
	override func invalidateLayout() {
		self.cache.removeAll()
		super.invalidateLayout()
	}
	
	// Doit invalider le layout ou non ?
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
	
	// Les attributs des éléments visibles dans le rect
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		var visibleAttribute: [UICollectionViewLayoutAttributes] = []
		
		for attribute in self.cache.values {
			if attribute.frame.intersects(rect) {
				visibleAttribute.append(attribute)
			}
		}
		
		return visibleAttribute.isEmpty ? nil : visibleAttribute
	}
	
	// L'attribut d'un élément à l'indexPath
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return self.cache[indexPath]
	}
	
	// Prepare un élément (origin, frame) et l'ajoute au cache
	private func prepareElement(of size: CGSize, with attributes: UICollectionViewLayoutAttributes) {
		let frame = self.frameForCell(of: size, with: attributes)
		attributes.frame = frame
		
		self.cache[attributes.indexPath] = attributes
	}
	
	// La frame d'une cellule
	private func frameForCell(of size: CGSize, with attributes: UICollectionViewLayoutAttributes) -> CGRect {
		let origin = originForCell(of: size, with: attributes)
		let frame = CGRect(origin: origin, size: size)
		
		return frame.inset(by: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
	}
	
	// L'origine d'une cellule
	private func originForCell(of size: CGSize, with attributes: UICollectionViewLayoutAttributes) -> CGPoint {
		let keyboardOrigin = self.keyboardOrigin
		
		let y = size.height * CGFloat(attributes.indexPath.section) + keyboardOrigin.y
		
		let cellsInRow = self.numberOfItems(inSection: attributes.indexPath.section)
		let availableWidth = self.collectionViewWidth
		
		let offset = (availableWidth - (CGFloat(cellsInRow) * size.width)) / 2
		let x = offset + size.width * CGFloat(attributes.indexPath.row)
		
		return CGPoint(x: x, y: y)
	}
}
