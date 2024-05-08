//
//  InfiniteGridVM.swift
//  Mapping
//
//  Created by Lê Văn Huy on 6/5/24.
//

import Foundation
import SwiftUI
class InfiniteGridVM: ObservableObject {
	@Published var gScale: CGFloat = 1
	@Published var sInteractionPoint: CGPoint = .zero
	
	private(set) var sSize: CGSize = .zero
	@Published var sTranslation: CGPoint = .zero
	
	public let sLineSpacing: CGFloat
	public let smallestAllowedLineGap: CGFloat
	public let largestAllowedLineGap: CGFloat
	
	init(baseScale: CGFloat = 1, smallestAllowedLineGap: CGFloat, largestAllowedLineGap: CGFloat) {
		self.sLineSpacing = 40 * baseScale
		self.smallestAllowedLineGap = smallestAllowedLineGap
		self.largestAllowedLineGap = largestAllowedLineGap
	}
	
	public func updateTranslation(newTranslation sTranslation: CGSize) {
		if !(sTranslation.width.isFinite && sTranslation.height.isFinite) {
			return
		}
		self.sTranslation += sTranslation / gScale
	}
	
	public func updateScale(newScale inputScaleMultiplier: CGFloat, sInteractionPoint: CGPoint) {
		if !inputScaleMultiplier.isFinite {
			return
		}
		var scaleMultiplier = inputScaleMultiplier
		if gScale * scaleMultiplier * sLineSpacing < smallestAllowedLineGap {
			scaleMultiplier = smallestAllowedLineGap / (gScale * sLineSpacing)
		}
		else if gScale * scaleMultiplier * sLineSpacing > largestAllowedLineGap {
			scaleMultiplier = largestAllowedLineGap / (gScale * sLineSpacing)
		}

		/* Process:
		 1. Determine how far inward the gesture occured in a 0-1 scale (interaction proportion)
		 2. Determine number of grid points displayed on screen in previous frame
		 3. Determine number of grid point displayed on screen in current frame
		 4. Determine the delta
		 5. Determine how many grid points were "pushed" left and up via the interaction proportion.
		 6. Add this value to the existing translation, update the scale value, and save the newest interaction point.
		 */
			
		let oldInteractionProportion = sInteractionPoint / sSize
		if !(oldInteractionProportion.x.isFinite && oldInteractionProportion.y.isFinite) {
			return
		}
		let oldDisplayedGridPoints = sSize / gScale
		let newDisplayedGridPoints = sSize / (gScale * scaleMultiplier)
		let deltaDisplayedGridPoints = newDisplayedGridPoints - oldDisplayedGridPoints
		let displacedTopLeftGridPoints = deltaDisplayedGridPoints * oldInteractionProportion
		sTranslation += displacedTopLeftGridPoints
		gScale *= scaleMultiplier
		self.sInteractionPoint = sInteractionPoint
	}
	
	public func setScreenSize(_ screenSize: CGSize) {
		// Ensure valid dimensions
		if !(screenSize.width.isFinite && screenSize.height.isFinite) {
			return
		}
		if screenSize.width * screenSize.height < 1 {
			return
		}
		self.sSize = screenSize
	}
	
	@MainActor
	public func drawGrid() -> Path {
		/// Grid to modify and return.
		var path: Path = Path()
		if gScale <= .zero {
			return path
		}
		let squareSpacing = sLineSpacing * gScale
		print(squareSpacing)
		if squareSpacing < 80 || squareSpacing > 160 {
			self.gScale = 1.0
		}
		
		// Calculate center of the view
		let centerX = sSize.width / 2 + sTranslation.x
		let centerY = sSize.height / 2 + sTranslation.y
		
		
		// Vertical lines from center
		var pos: CGFloat = centerX
		while pos >= 0 {
			path.move(to: CGPoint(x: pos, y: 0))
			path.addLine(to: CGPoint(x: pos, y: sSize.height))
			pos -= sLineSpacing * gScale
		}
		pos = centerX + sLineSpacing * gScale
		while pos < sSize.width {
			path.move(to: CGPoint(x: pos, y: 0))
			path.addLine(to: CGPoint(x: pos, y: sSize.height))
			pos += sLineSpacing * gScale
		}
		
		// Horizontal lines from center
		pos = centerY
		while pos >= 0 {
			path.move(to: CGPoint(x: 0, y: pos))
			path.addLine(to: CGPoint(x: sSize.width, y: pos))
			pos -= sLineSpacing * gScale
		}
		pos = centerY + sLineSpacing * gScale
		while pos < sSize.height {
			path.move(to: CGPoint(x: 0, y: pos))
			path.addLine(to: CGPoint(x: sSize.width, y: pos))
			pos += sLineSpacing * gScale
		}
		
		return path
	}

	
	@MainActor
	public func drawSmallGrid() -> Path {
		/// Grid to modify and return.
		var path: Path = Path()
		if gScale <= .zero {
			return path
		}
		let smallSquareSpacing = sLineSpacing * gScale / 5 // Small grid spacing
		
		// Calculate center of the view
		let centerX = sSize.width / 2 + sTranslation.x
		let centerY = sSize.height / 2 + sTranslation.y
		
		// Vertical lines from center
		var pos: CGFloat = centerX
		while pos >= 0 {
			path.move(to: CGPoint(x: pos, y: 0))
			path.addLine(to: CGPoint(x: pos, y: sSize.height))
			pos -= smallSquareSpacing
		}
		pos = centerX + smallSquareSpacing
		while pos < sSize.width {
			path.move(to: CGPoint(x: pos, y: 0))
			path.addLine(to: CGPoint(x: pos, y: sSize.height))
			pos += smallSquareSpacing
		}
		
		// Horizontal lines from center
		pos = centerY
		while pos >= 0 {
			path.move(to: CGPoint(x: 0, y: pos))
			path.addLine(to: CGPoint(x: sSize.width, y: pos))
			pos -= smallSquareSpacing
		}
		pos = centerY + smallSquareSpacing
		while pos < sSize.height {
			path.move(to: CGPoint(x: 0, y: pos))
			path.addLine(to: CGPoint(x: sSize.width, y: pos))
			pos += smallSquareSpacing
		}
		
		return path
	}

}
