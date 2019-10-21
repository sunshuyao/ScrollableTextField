//
//  ScrollableTextField.swift
//  ScrollableTextField
//
//  Created by Sun,Shuyao on 2019/10/21.
//  Copyright © 2019 Sun,Shuyao. All rights reserved.
//

import UIKit

private enum TextRangeChangedType: Int {
    case leftAndBack = 0
    case leftAndForward
    case rightAndBack
    case rightAndForward
    case none
}

public class ScrollableTextField: UIView {
    
    /// Real textFiled.
    ///
    /// You should set delegate, add actions or resign first responder  to this view.
    private(set) var textField: UITextField?
    
    // MARK: - Private
    
    private let oneCutWidth: CGFloat = UIScreen.main.bounds.width
    
    private let defaultCutTimes: CGFloat = 3
    
    private var scrollView: UIScrollView?
    
    private weak var tapGesture: UITapGestureRecognizer?
    
    private weak var textFiledWidthConstraint: NSLayoutConstraint?
    
    // MARK: - Private funcs
    
    private func configureSubviews() {
        //scroll
        scrollView = UIScrollView(frame: .zero)
        if let scrollView = scrollView {
            scrollView.contentSize = CGSize(width: oneCutWidth * defaultCutTimes, height: 0)
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.bounces = false
            scrollView.delegate = self
            scrollView.backgroundColor = .clear
            self.addSubview(scrollView)
            // if not using masonry
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            let scrollLeftConstraint = NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let scrollRightConstraint = NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            let scrollTopConstraint = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            let scrollBottomConstraint = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            self.addConstraints([scrollLeftConstraint, scrollRightConstraint, scrollTopConstraint, scrollBottomConstraint])
//            scrollView.mas_makeConstraints {[weak self] (make) in // if use masonry
//                make?.edges.equalTo()(self)
//            }
            
            //text field
            textField = InnerTextField(frame: .zero)
            let oneCut = oneCutWidth
            let times = defaultCutTimes
            if let textField = textField as? InnerTextField {
                textField.addTarget(self, action: #selector(handleTextField(_:)), for: .editingChanged)
                
                let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                gesture.delegate = self
                textField.addGestureRecognizer(gesture)
                tapGesture = gesture
                
                textField.selectedTextRangeChangedBlock = {[weak self] (type, width) in
                    guard let scrollView = self?.scrollView else {
                        return
                    }
                    
                    let div: CGFloat = 15
                    if width < scrollView.contentOffset.x + div {
                        UIView.animate(withDuration: 0.1, animations: {
                            scrollView.contentOffset.x = max(width - div, 0)
                        })
                    } else if width > scrollView.contentOffset.x + scrollView.bounds.width - div {
                        UIView.animate(withDuration: 0.1, animations: {
                            scrollView.contentOffset.x = width - scrollView.bounds.width + div
                        })
                    }
                }
                scrollView.addSubview(textField)
                // if not using masonry
                textField.translatesAutoresizingMaskIntoConstraints = false
                let textLeftConstaint = NSLayoutConstraint(item: textField, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 0)
                let textTopConstrait = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
                let textBottomConstrait = NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
                let textWidthConstrait = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: oneCut * times)
                scrollView.addConstraint(textLeftConstaint)
                self.addConstraints([textTopConstrait, textBottomConstrait])
                textField.addConstraint(textWidthConstrait)
                textFiledWidthConstraint = textWidthConstrait
//                textField.mas_makeConstraints {[weak self] (make) in // if use masonry
//                    make?.left.equalTo()(scrollView)
//                    make?.top.and()?.bottom()?.equalTo()(self)
//                    make?.width.equalTo()(oneCut * times)
//                }
            }
            
        }
    }
    
    // MARK: - Life circle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: textField)
        let cloestPosition = textField?.closestPosition(to: point)
        if let cloestPosition = cloestPosition {
            textField?.selectedTextRange = textField?.textRange(from: cloestPosition, to: cloestPosition)
        }
    }
    
    @objc private func handleTextField(_ textField: UITextField) {
        
        guard let scrollView = self.scrollView, let hookedTF = textField as? InnerTextField else {
            return
        }
        
        guard let width = hookedTF.getWidthFromDocumentBeginingToCursor(), let fullWidth = hookedTF.getWidthFromDocumentBeginingToEnd() else {
            return
        }
        
        let selfWidth = self.bounds.width
        if selfWidth == 0 {
            return
        }
        //check max bounds
        if scrollView.contentSize.width - fullWidth < oneCutWidth {
            if scrollView.contentSize.width <= fullWidth {
                scrollView.contentSize.width = fullWidth + oneCutWidth
            } else {
                scrollView.contentSize.width += oneCutWidth
            }
            // if not using masonry
            textFiledWidthConstraint?.constant = scrollView.contentSize.width
            //            textField.mas_updateConstraints { (make) in // if use masonry
            //                make?.width.equalTo()(scrollView.contentSize.width)
            //            }
            self.layoutIfNeeded()
        }
        if width >= selfWidth - 3 {
            if width - scrollView.contentOffset.x >= 0 && width - scrollView.contentOffset.x < selfWidth {
                return
            }
            let diff = max(width - selfWidth + 3, 0)
            scrollView.contentOffset.x = diff
        } else {
            scrollView.contentOffset.x = 0
        }
    }
}

// MARK: - Delegate

extension ScrollableTextField: UIScrollViewDelegate, UIGestureRecognizerDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let currentTextWidth = (textField as? InnerTextField)?.getWidthFromDocumentBeginingToEnd() else {
            return
        }
        let selfFrame = self.frame
        if currentTextWidth < selfFrame.width {
            scrollView.contentOffset.x = 0
            return
        }
        let maxOffsetX = currentTextWidth - selfFrame.width + 6
        if scrollView.contentOffset.x > maxOffsetX {
            scrollView.contentOffset.x = maxOffsetX
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.tapGesture {
            if self.textField?.isFirstResponder ?? false {
                return true
            } else {
                return false
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}

// MARK: - Private class

private class InnerTextField: UITextField {
    
    // MARK: - Public
    
    func getWidthFromDocumentBeginingToCursor() -> CGFloat? {
        guard let selectedRange = self.selectedTextRange else {
            return nil
        }

        let width = getWidthFromDocumentBegining(to: selectedRange.start)
        
        return width
    }
    
    func getWidthFromDocumentBeginingToEnd() -> CGFloat? {
        guard let str = self.text else {
            return nil
        }

        let width = getWidthFrom(string: str)
        
        return width
    }
    
    // MARK: - Private
    
    private func changeType(oldRange: UITextRange, newRange: UITextRange) -> TextRangeChangedType {
        let oldStart = self.offset(from: beginningOfDocument, to: oldRange.start)
        let oldEnd = self.offset(from: beginningOfDocument, to: oldRange.end)
        
        let newStart = self.offset(from: beginningOfDocument, to: newRange.start)
        let newEnd = self.offset(from: beginningOfDocument, to: newRange.end)
        
        if (oldStart == newStart) && (oldEnd != newEnd) {
            if (newEnd > oldEnd) {
                return .rightAndForward
            } else if (newEnd < oldEnd) {
                return .rightAndBack
            }
            return .none
        }
        if (oldStart != newStart) && (oldEnd == newEnd) {
            if (newStart < oldStart) {
                return .leftAndBack
            } else if (newStart > oldStart) {
                return .leftAndForward
            }
            return .none
        }
        if (oldStart == oldEnd) && (newStart == newEnd) {
            if newStart > oldStart {
                return .rightAndForward
            } else if newStart < oldStart {
                return .leftAndBack
            }
        }
        return .none
    }
    
    private func getWidthFrom(string text: String) -> CGFloat {
        let label = UILabel(frame: .zero)
        label.text = text
        var defaultFont = UIFont.systemFont(ofSize: 15)
        if let font = self.font {
            defaultFont = font
        }
        label.font = defaultFont
        label.sizeToFit()
        let width = label.bounds.size.width
        return width
    }
    
    private func getWidthFromDocumentBegining(to position: UITextPosition) -> CGFloat? {
        if let textStr = self.text {
            let curText = textStr as NSString
            let offset = self.offset(from: beginningOfDocument, to: position)
            
            guard offset <= curText.length && offset >= 0 else {
                return nil
            }
            let subStr = curText.substring(to: offset)
            
            let width = getWidthFrom(string: subStr)
            return width
        }
        return nil
    }
    
    override var text: String? {
        didSet {
            self.sendActions(for: .editingChanged)
        }
    }
    
    override var selectedTextRange: UITextRange? {
        willSet {
            if let old = selectedTextRange, let `new` = newValue {
                let willChangeType = changeType(oldRange: old, newRange: new)
                if willChangeType == .leftAndBack || willChangeType == .leftAndForward {
                    if let width = getWidthFromDocumentBegining(to: new.start) {
                        selectedTextRangeChangedBlock?(willChangeType, width)
                    }
                } else if willChangeType == .rightAndForward || willChangeType == .rightAndBack {
                    if let width = getWidthFromDocumentBegining(to: new.end) {
                        selectedTextRangeChangedBlock?(willChangeType, width)
                    }
                }
            }
        }
    }
    
    var selectedTextRangeChangedBlock: ((_ changType: TextRangeChangedType, _ beforeTextWidth: CGFloat) -> ())?
}
