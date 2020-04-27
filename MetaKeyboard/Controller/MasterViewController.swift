//
//  MasterViewController.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 23/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

	/// Le slider de température
	@IBOutlet weak var temperatureSlider: UISlider!
	
	/// Le label affichant la température
	@IBOutlet weak var temperatureLabel: UILabel!
	
	/// Le bouton permettant de choisir son fichier des fréquences
	@IBOutlet weak var frequenciesButton: UIButton!
	
	/// Le score du clavier affiché par la simulation
	@IBOutlet weak var scoreLabel: UILabel!
	
	/// Le bouton permettant de lancer la simulation
	@IBOutlet weak var startButton: UIButton!
	
	/// Le bouton permettant d'arrêter la simulation
	@IBOutlet weak var stopButton: UIButton!
	
	/// Quand la température change dans la simulation
	@IBAction func temperatureChanged(_ sender: UISlider) {
		self.temperatureLabel.text = "\(Int(sender.value))°"
	}
	
	/// Définit le fichier des fréquences de la simulation
	@IBAction func setFrequenciesFile(_ sender: UIButton) {
		let dialog = UIDocumentPickerViewController(documentTypes: ["public.plain-text"], in: .open)
		if #available(iOS 11.0, *) {
			dialog.allowsMultipleSelection = false
		}
		
		dialog.delegate = self
		
		self.present(dialog, animated: true, completion: nil)
	}
	
	/// Permet de réchauffer la simulation
	@IBAction func boid(_ sender: UIButton) {
		self.detailViewController?.boil(10)
	}
	/// Permet de lancer la simulation
	@IBAction func startSimulation(_ sender: UIButton) {
		
		// Si la vue de la simulation est définie
		guard let detailViewController = self.detailViewController else {
			self.error(message: "La vue de la simulation n'est pas définie")
			return
		}
		
		// Si des fréquences ont étés définies
		guard detailViewController.frequencies != nil else {
			self.error(message: "Il faut d'abord définir le fichier des fréquences")
			return
		}
		
		// On récupère la température
		guard var temperatureText = self.temperatureLabel.text else {
			self.error(message: "La température est invalide")
			return
		}
		
		temperatureText.removeLast()
		
		guard let temperature = Int(temperatureText) else {
			self.error(message: "La température est invalide")
			return
		}
		
		// Prêt à simuler, on désactive le bouton de simulation
		sender.isEnabled = false
		
		self.stopButton.isEnabled = true
		
		// Nouvelle simulation
		detailViewController.start(temperature: Double(temperature))
	}
	
	@IBAction func stopSimulation(_ sender: UIButton) {
		self.detailViewController?.stop()
		sender.isEnabled = false
		self.startButton.isEnabled = true
	}
	
	@IBAction func toggleView(_ sender: UISegmentedControl) {
		self.detailViewController?.shouldPresentBestState = (sender.selectedSegmentIndex == 1)
		
		// Si la simulation est arrêtée
		if !self.stopButton.isEnabled {
			
			// On force le rafrachissiement
			self.detailViewController?.collectionView.reloadData()
		}
		
	}
	
	/// La vue de la simulation
	var detailViewController: KeyboardViewController? = nil

	/// Parle de lui même ?
	override func viewDidLoad() {
		super.viewDidLoad()
		if let split = splitViewController {
		    let controllers = split.viewControllers
			self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? KeyboardViewController
			self.detailViewController?.delegate = self
		}
		
	}
	
	/// Reset le bouton des fréquences
	private func resetFrequeciesButton() {
		self.frequenciesButton.titleLabel?.text = "Définir les fréquences"
		self.frequenciesButton.isEnabled = true
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return false
	}

}

extension MasterViewController: UIDocumentPickerDelegate {
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		
		//self.frequenciesButton.isEnabled = false
		guard let url = urls.first else {
			return
		}
		
		guard url.startAccessingSecurityScopedResource() else {
			// Handle the failure here.
			self.error(message: "Impossible d'accéder à la ressource")
			return
		}
		
		// Make sure you release the security-scoped resource when you are done.
		defer { url.stopAccessingSecurityScopedResource() }
		
		// Do something with the file here.
		let parser = BigramParser()
				
		do {
			try parser.parseFile(url)
			
			guard let matrix = parser.matrix else {
				self.error(message: "Impossible de parser les fréquences") {
					self.resetFrequeciesButton()
				}
				return
			}
			
			let frequencies = BigramFrequencies(grid: matrix)
			frequencies.normalize()
			
			#if os(iOS)
			if let split = splitViewController {
				let controllers = split.viewControllers
				self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? KeyboardViewController
				self.detailViewController?.delegate = self
			}
			#endif
			
			self.detailViewController?.frequencies = frequencies
			
			self.frequenciesButton.setTitle(url.lastPathComponent, for: .normal)
			self.frequenciesButton.isEnabled = true
		} catch {
			self.error(message: "\(error)") {
				self.resetFrequeciesButton()
			}
					
		}
			
	}
	
}

extension MasterViewController: KeyboardViewControllerDelegate {
	
	func keyboardViewController(_ keyboardViewController: KeyboardViewController, didChangeScore score: Double) {
		self.scoreLabel.text = "\(round(score))"
	}
	
	func keyboardViewController(_ keyboardViewController: KeyboardViewController, didChangeTemperature temperature: Double) {
		self.temperatureSlider.value = Float(temperature)
		self.temperatureChanged(self.temperatureSlider)
	}
	
}
