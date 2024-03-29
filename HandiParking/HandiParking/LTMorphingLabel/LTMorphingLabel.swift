//
//  LTMorphingLabel.swift
//  https://github.com/lexrus/LTMorphingLabel
//
//  The MIT License (MIT)
//  Copyright (c) 2015 Lex Tang, http://LexTang.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit
import QuartzCore


let LTMorphingPhaseStart = "Start"
let LTMorphingPhaseAppear = "Appear"
let LTMorphingPhaseDisappear = "Disappear"
let LTMorphingPhaseDraw = "Draw"
let LTMorphingPhaseManipulateProgress = "ManipulateProgress"
let LTMorphingPhaseSkipFrames = "SkipFrames"


typealias LTMorphingStartClosure = (Void) -> Void
typealias LTMorphingEffectClosure = (Character, index: Int, progress: Float) -> LTCharacterLimbo
typealias LTMorphingDrawingClosure = LTCharacterLimbo -> Bool
typealias LTMorphingManipulateProgressClosure = (index: Int, progress: Float, isNewChar: Bool) -> Float
typealias LTMorphingSkipFramesClosure = (Void) -> Int


@objc public protocol LTMorphingLabelDelegate {
    optional func morphingDidStart(label: LTMorphingLabel)
    optional func morphingDidComplete(label: LTMorphingLabel)
    optional func morphingOnProgress(label: LTMorphingLabel, _ progress: Float)
}


// MARK: - LTMorphingLabel
//@IBDesignable
public class LTMorphingLabel: UILabel {
    
    public var morphingProgress: Float = 0.0
    public var morphingDuration: Float = 0.6
    public var morphingCharacterDelay: Float = 0.026
    public var morphingEffect: LTMorphingEffect = .Scale
    public var delegate: LTMorphingLabelDelegate?
    
    var _startClosures = [String: LTMorphingStartClosure]()
    var _effectClosures = [String: LTMorphingEffectClosure]()
    var _drawingClosures = [String: LTMorphingDrawingClosure]()
    var _progressClosures = [String: LTMorphingManipulateProgressClosure]()
    var _skipFramesClosures = [String: LTMorphingSkipFramesClosure]()
    var _diffResults = [LTCharacterDiffResult]()
    var _originText = ""
    var _currentFrame = 0
    var _totalFrames = 0
    var _totalDelayFrames = 0
    var _totalWidth: Float = 0.0
    let _characterOffsetYRatio = 1.1
    var _originRects = [CGRect]()
    var _newRects = [CGRect]()
    var _charHeight: CGFloat = 0.0
    var _skipFramesCount: Int = 0
    
    #if !TARGET_INTERFACE_BUILDER
    override public var text:String! {
        get {
            return super.text
        }
        set {
            _originText = text ?? ""
            _diffResults = _originText >> (newValue ?? "")
            super.text = newValue ?? ""
            
            morphingProgress = 0.0
            _currentFrame = 0
            _totalFrames = 0
            
            self.setNeedsLayout()
            
            if _originText != text {
                displayLink.paused = false
                if let closure = _startClosures["\(morphingEffect.description)\(LTMorphingPhaseStart)"] {
                    return closure()
                }
                
                if let didStart = delegate?.morphingDidStart {
                    didStart(self)
                }
            }
        }
    }
    
    public override func setNeedsLayout() {
        super.setNeedsLayout()
        _originRects = rectsOfEachCharacter(_originText, withFont: self.font)
        _newRects = rectsOfEachCharacter(self.text ?? "", withFont: self.font)
    }
    
    override public var bounds:CGRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
            self.setNeedsLayout()
        }
    }
    
    override public var frame:CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.setNeedsLayout()
        }
    }
    #endif
    
    private lazy var displayLink: CADisplayLink = {
        let _displayLink = CADisplayLink(
            target: self,
            selector: Selector("_displayFrameTick"))
        _displayLink.addToRunLoop(
            NSRunLoop.currentRunLoop(),
            forMode: NSRunLoopCommonModes)
        return _displayLink
        }()
    
    lazy var emitterView: LTEmitterView = {
        let _emitterView = LTEmitterView(frame: self.bounds)
        self.addSubview(_emitterView)
        return _emitterView
        }()
}

// MARK: - Animation extension
extension LTMorphingLabel {
    
    func _displayFrameTick() {
        if displayLink.duration > 0.0 && _totalFrames == 0 {
            let frameRate = Float(displayLink.duration) / Float(displayLink.frameInterval)
            _totalFrames = Int(ceil(morphingDuration / frameRate))
            
            let totalDelay = Float(count(self.text!)) * morphingCharacterDelay
            _totalDelayFrames = Int(ceil(totalDelay / frameRate))
        }
        
        if _originText != text && _currentFrame++ < _totalFrames + _totalDelayFrames + 5 {
            morphingProgress += 1.0 / Float(_totalFrames)
            
            if let closure = self._skipFramesClosures["\(self.morphingEffect.description)\(LTMorphingPhaseSkipFrames)"] {
                if ++_skipFramesCount > closure() {
                    _skipFramesCount = 0
                    setNeedsDisplay()
                }
            } else {
                setNeedsDisplay()
            }
            
            if let onProgress = delegate?.morphingOnProgress {
                onProgress(self, morphingProgress)
            }
        } else {
            displayLink.paused = true
            
            if let complete = delegate?.morphingDidComplete {
                complete(self)
            }
        }
    }
    
    // Could be enhanced by kerning text:
    // http://stackoverflow.com/questions/21443625/core-text-calculate-letter-frame-in-ios
    func rectsOfEachCharacter(textToDraw:String, withFont font:UIFont) -> [CGRect] {
        var charRects = [CGRect]()
        var leftOffset: CGFloat = 0.0
        
        if _charHeight == 0.0 {
            _charHeight = "LEX".sizeWithAttributes([NSFontAttributeName: self.font]).height
        }
        var topOffset = (self.bounds.size.height - _charHeight) / 2.0
        
        for (i, char) in enumerate(textToDraw) {
            let charSize = String(char).sizeWithAttributes([NSFontAttributeName: self.font])
            charRects.append(CGRect(origin: CGPointMake(leftOffset, topOffset), size: charSize))
            leftOffset += charSize.width
        }
        
        _totalWidth = Float(leftOffset)
        
        var stringLeftOffSet: CGFloat = 0.0
        
        switch textAlignment {
        case .Center:
            stringLeftOffSet = CGFloat((Float(bounds.size.width) - _totalWidth) / 2.0)
        case .Right:
            stringLeftOffSet = CGFloat(Float(bounds.size.width) - _totalWidth)
        default:
            ()
        }
        
        var offsetedCharRects = [CGRect]()
        
        for r in charRects {
            offsetedCharRects.append(CGRectOffset(r, stringLeftOffSet, 0.0))
        }
        
        return offsetedCharRects
    }
    
    func limboOfOriginalCharacter(
        char: Character,
        index: Int,
        progress: Float) -> LTCharacterLimbo {
            
            var currentRect = _originRects[index]
            let oriX = Float(currentRect.origin.x)
            var newX = Float(currentRect.origin.x)
            let diffResult = _diffResults[index]
            var currentFontSize: CGFloat = font.pointSize
            var currentAlpha: CGFloat = 1.0
            
            switch diffResult.diffType {
                // Move the character that exists in the new text to current position
            case .Move, .MoveAndAdd, .Same:
                newX = Float(_newRects[index + diffResult.moveOffset].origin.x)
                currentRect.origin.x = CGFloat(LTEasing.easeOutQuint(progress, oriX, newX - oriX))
            default:
                // Otherwise, remove it
                
                // Override morphing effect with closure in extenstions
                if let closure = _effectClosures["\(morphingEffect.description)\(LTMorphingPhaseDisappear)"] {
                    return closure(char, index: index, progress: progress)
                } else {
                    // And scale it by default
                    currentFontSize = font.pointSize - CGFloat(LTEasing.easeOutQuint(progress, 0, Float(font.pointSize)))
                    currentAlpha = CGFloat(1.0 - progress)
                    currentRect = CGRectOffset(_originRects[index], 0,
                        CGFloat(font.pointSize - currentFontSize) / CGFloat(_characterOffsetYRatio))
                }
            }
            
            return LTCharacterLimbo(
                char: char,
                rect: currentRect,
                alpha: currentAlpha,
                size: currentFontSize,
                drawingProgress: 0.0
            )
    }
    
    func limboOfNewCharacter(
        char: Character,
        index: Int,
        progress: Float) -> LTCharacterLimbo {
            
            var currentRect = _newRects[index]
            var newX = Float(currentRect.origin.x)
            var currentFontSize = CGFloat(LTEasing.easeOutQuint(progress, 0, Float(font.pointSize)))
            var currentAlpha:CGFloat = CGFloat(morphingProgress)
            var yOffset: CGFloat = 0.0
            
            if let closure = _effectClosures["\(morphingEffect.description)\(LTMorphingPhaseAppear)"] {
                return closure(char, index: index, progress: progress)
            } else {
                currentFontSize = CGFloat(LTEasing.easeOutQuint(progress, 0.0, Float(font.pointSize)))
                let yOffset = CGFloat(font.pointSize - currentFontSize) / CGFloat(_characterOffsetYRatio)
                
                return LTCharacterLimbo(
                    char: char,
                    rect: CGRectOffset(currentRect, 0.0, yOffset),
                    alpha: CGFloat(morphingProgress),
                    size: currentFontSize,
                    drawingProgress: 0.0
                )
            }
    }
    
    func limboOfCharacters() -> [LTCharacterLimbo] {
        let fontSize = font.pointSize
        var limbo = [LTCharacterLimbo]()
        
        // Iterate original characters
        for (i, character) in enumerate(_originText) {
            var progress: Float = 0.0
            
            if let closure = _progressClosures["\(morphingEffect.description)\(LTMorphingPhaseManipulateProgress)"] {
                progress = closure(index: i, progress: morphingProgress, isNewChar: false)
            } else {
                progress = min(1.0, max(0.0, morphingProgress + morphingCharacterDelay * Float(i)))
            }
            
            let limboOfCharacter = limboOfOriginalCharacter(character, index: i, progress: progress)
            limbo.append(limboOfCharacter)
        }
        
        // Add new characters
        for (i, character) in enumerate(text!) {
            if i >= _diffResults.count {
                break
            }
            
            var progress: Float = 0.0
            
            if let closure = _progressClosures["\(morphingEffect.description)\(LTMorphingPhaseManipulateProgress)"] {
                progress = closure(index: i, progress: morphingProgress, isNewChar: true)
            } else {
                progress = min(1.0, max(0.0, morphingProgress - morphingCharacterDelay * Float(i)))
            }
            
            // Don't draw character that already exists
            let diffResult = _diffResults[i]
            if diffResult.skip {
                continue
            }
            
            switch diffResult.diffType {
            case .MoveAndAdd, .Replace, .Add, .Delete:
                let limboOfCharacter = limboOfNewCharacter(character, index: i, progress: progress)
                limbo.append(limboOfCharacter)
            default:
                ()
            }
        }
        
        return limbo
    }
}


// MARK: - Drawing extension
extension LTMorphingLabel {
    override public func didMoveToSuperview() {
        if let s = self.text {
            self.text = s
        }
        
        // Load all morphing effects
        for effectName: String in LTMorphingEffect.allValues {
            let effectFunc = Selector("\(effectName)Load")
            if respondsToSelector(effectFunc) {
                NSTimer(timeInterval: 0.0, target: self, selector: effectFunc, userInfo: nil, repeats: false).fire()
            }
        }
    }
    
    override public func drawTextInRect(rect: CGRect) {
        for charLimbo in limboOfCharacters() {
            var charRect:CGRect = charLimbo.rect
            
            let willAvoidDefaultDrawing: Bool = {
                if let closure = self._drawingClosures["\(self.morphingEffect.description)\(LTMorphingPhaseDraw)"] {
                    return closure($0)
                }
                return false
                }(charLimbo)
            
            if !willAvoidDefaultDrawing {
                let s = String(charLimbo.char)
                s.drawInRect(charRect, withAttributes: [
                    NSFontAttributeName: self.font.fontWithSize(charLimbo.size),
                    NSForegroundColorAttributeName: self.textColor.colorWithAlphaComponent(charLimbo.alpha)
                    ])
            }
        }
    }
}

