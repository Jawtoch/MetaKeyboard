//
//  DetailViewController.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 23/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import UIKit

public class KeyboardViewController: UICollectionViewController {
	
	/// Le clavier de départ
	private var keyboard: Keyboard = Keyboard(rows: 4, columns: 10)
	
	/// Les fréquences
	public var frequencies: BigramFrequencies?
	
	/// Si la vue doit afficher uniquement le meilleur état
	public var shouldPresentBestState: Bool = false
	
	/// Le délégué
	public var delegate: KeyboardViewControllerDelegate?
	
	/// L'algorithme de recuit simulé
	private var annealedKeyboard: Annealed<Keyboard>?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		self.collectionView.contentInset = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
		self.keyboard.shuffle()
		
	}
	
	/// Démarre une simulation de recuit
	public func start(temperature: Double) {
		guard let frequencies = self.frequencies else {
			return
		}
		
		let keyboardRater = KeyboardRater(frequencies: frequencies)
		
		let annealedKeyboard = Annealed<Keyboard>()
		self.annealedKeyboard = annealedKeyboard
		annealedKeyboard.delegate = self
		
		annealedKeyboard.start(
			initialeState: self.keyboard,
			temperature: temperature, nextState: { $0.smallShuffle()! },
			energyForState: { keyboardRater.rateKeyboard($0) })
	}
	
	/// Arrête la simulation de recuit
	public func stop() {
		self.annealedKeyboard?.stop()
		self.annealedKeyboard = nil
	}
	
	/// Augmente la température de la simulation
	public func boil(_ t: Double) {
		self.annealedKeyboard?.boil(t)
	}
	
	// MARK: - UICollectionViewDataSource
	public override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.keyboard.rows
	}
	
	public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.keyboard.columns
	}
	
	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyCell", for: indexPath)
		
		if let cell = cell as? KeyCollectionViewCell {
			
			if self.shouldPresentBestState, let state = self.annealedKeyboard?.bestState?.state {
				cell.key = "\(state.characterForItem(at: indexPath))"
			} else {
				cell.key = "\(self.keyboard.characterForItem(at: indexPath))"
			}
			
			cell.layer.cornerRadius = cell.frame.width / 16
			cell.layer.shadowColor = UIColor.black.cgColor
			cell.layer.shadowOpacity = 0.3
			cell.layer.shadowOffset = .zero
			cell.layer.shadowRadius = 4
			cell.layer.masksToBounds = false
			
			cell.contentView.clipsToBounds = true
		}
		
		return cell
	}
	
	public override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		if let cell = collectionView.cellForItem(at: indexPath) {
			cell.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
		}
		
	}
	
	public override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		if let cell = collectionView.cellForItem(at: indexPath) {
			UIView.animate(withDuration: 0.2) {
				if #available(iOS 13.0, *) {
					cell.backgroundColor = .systemGray4
				} else {
					// Fallback on earlier versions
					cell.backgroundColor = .lightGray
				}
				
			}
			
		}
		
	}
	
}

extension KeyboardViewController: AnnealedDelegate {
	public func annealed(_ annealed: Any, didAcceptNewState state: Any, with energy: Double, temperature: Double) {
		DispatchQueue.main.async {
			// Enregister le nouvel état
			self.keyboard = state as! Keyboard
			
			// Rafraichir la vue
			self.collectionView.reloadData()
			
			// Prévenir le délégué
			self.delegate?.keyboardViewController(self, didChangeScore: energy)
			self.delegate?.keyboardViewController(self, didChangeTemperature: temperature)
		}
		
	}
	
}
