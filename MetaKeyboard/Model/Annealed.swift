//
//  Annealed.swift
//  MetaKeyboard
//
//  Created by Ugo Cottin on 24/04/2020.
//  Copyright © 2020 Ugo Cottin. All rights reserved.
//

import Foundation

public class Annealed<T> {
	
	public var delegate: AnnealedDelegate?
	
	private var supplementaryHeat: Double?
	
	private var workItem: DispatchWorkItem?
	
	public var bestState: (state: T, energy: Double)?
	
	/// Simule un recuit
	/// - Parameters:
	///   - initialeState: état initial du système
	///   - minimalEnergy: l'énergie minimale à atteindre
	///   - temperature: la température initiale du système
	///   - nextState: la fonction permettant de récupérer l'état suivant du système
	///   - energyForState: la fonction permettant de calculer l'énergie d'un état du système
	public func start(initialeState: T, temperature: Double, nextState: @escaping((T) -> (T)), energyForState: @escaping((T) -> Double)) {
		var energy = energyForState(initialeState)
		
		var state = initialeState
		var tempe = temperature
		
		self.bestState = (state, energy)
		
		self.workItem = DispatchWorkItem {
			while !self.workItem!.isCancelled {
				
				// Nouvel état du système
				let ns = nextState(state)
				
				// Energie du nouvel état
				let ne = energyForState(ns)
				
				if let xe = self.bestState?.energy, ne < xe {
					self.bestState = (ns, ne)
				}
				
				tempe = self.temp(initialTemperature: tempe)
				if ne < energy || Double.random(in: 0 ... 1) < self.probability(delta: ne - energy, temperature: tempe) {
					state = ns
					energy = ne
					self.delegate?.annealed(self, didAcceptNewState: state, with: energy, temperature: tempe)
				}
				
			}
			
			self.workItem = nil
		}
		
		DispatchQueue.global().async(execute: self.workItem!)
	}
	
	public func stop() {
		DispatchQueue.global().asyncAfter(deadline: .now()) {
			self.workItem?.cancel()
		}
		
	}
	
	public func boil(_ t: Double) {
		self.supplementaryHeat = t
	}
	
	private func temp(initialTemperature: Double) -> Double {
		defer {
			self.supplementaryHeat = nil
		}
		
		return (initialTemperature + (self.supplementaryHeat ?? 0)) * 0.999
	}
	
	private func probability(delta: Double, temperature: Double) -> Double {
		return exp(-1 * delta / temperature)
	}
	
}
