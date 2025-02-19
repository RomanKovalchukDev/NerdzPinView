//
//  UnderlineItemView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import UIKit

public final class UnderlineItemView: PinTapableView, PinCodeItemViewType, ItemViewLayoutConfigurable, ItemViewAppearanceConfigurable {
    
    // MARK: - Internal types
    
    public struct LayoutConfig: DefaultableConfigType {
        public static var defaultValue: LayoutConfig = LayoutConfig()
        
        public var cursorCornerRadius: CGFloat
        public var cursorHeightMultiplier: CGFloat
        public var cursorWidth: CGFloat
        
        public var cornerRadius: CGFloat
        public var contentLabelEdgeInsets: UIEdgeInsets
        
        public init(
            cursorCornerRadius: CGFloat = 0.5,
            cursorHeightMultiplier: CGFloat = 0.7,
            cursorWidth: CGFloat = 1,
            cornerRadius: CGFloat = 0,
            underlineHeight: CGFloat = 2,
            contentLabelEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        ) {
            self.cursorCornerRadius = cursorCornerRadius
            self.cursorHeightMultiplier = cursorHeightMultiplier
            self.cursorWidth = cursorWidth
            self.cornerRadius = cornerRadius
            self.contentLabelEdgeInsets = contentLabelEdgeInsets
        }
    }
    
    // Implementation has a major flaw with duplicated properties
    public struct AppearanceConfig: DefaultableConfigType {
        
        public static let defaultValue: AppearanceConfig = AppearanceConfig()
        
        public var defaultBackgroundColor: UIColor
        // If state value valiables are nil -
        public var activeBackgroundColor: UIColor?
        public var errorBackgroundColor: UIColor?
        
        public var defaultValueColor: UIColor
        public var activeValueColor: UIColor?
        public var errorValueColor: UIColor?
        
        public var defaultUnderlineColor: UIColor
        public var activeUnderlineColor: UIColor?
        public var errorUnderlineColor: UIColor?
        
        public var defaultUnderlineHeight: CGFloat
        public var activeUnderlineHeight: CGFloat?
        public var errorUnderlineHeight: CGFloat?
        
        public var placeholderColor: UIColor
        public var cursorColor: UIColor
        public var font: UIFont
        
        // MARK: - Life cycle
        
        public init(
            defaultBackgroundColor: UIColor = .clear,
            activeBackgroundColor: UIColor? = nil,
            errorBackgroundColor: UIColor? = nil,
            defaultValueColor: UIColor = .black,
            activeValueColor: UIColor? = nil,
            errorValueColor: UIColor? = nil,
            defaultUnderlineColor: UIColor = .gray,
            activeUnderlineColor: UIColor? = .blue,
            errorUnderlineColor: UIColor? = nil,
            defaultUnderlineHeight: CGFloat = 2,
            activeUnderlineHeight: CGFloat? = nil,
            errorUnderlineHeight: CGFloat? = nil,
            placeholderColor: UIColor = .gray,
            cursorColor: UIColor = .blue,
            font: UIFont = .systemFont(ofSize: 14)
        ) {
            self.defaultBackgroundColor = defaultBackgroundColor
            self.activeBackgroundColor = activeBackgroundColor
            self.errorBackgroundColor = errorBackgroundColor
            self.defaultValueColor = defaultValueColor
            self.activeValueColor = activeValueColor
            self.errorValueColor = errorValueColor
            self.defaultUnderlineColor = defaultUnderlineColor
            self.activeUnderlineColor = activeUnderlineColor
            self.errorUnderlineColor = errorUnderlineColor
            self.defaultUnderlineHeight = defaultUnderlineHeight
            self.activeUnderlineHeight = activeUnderlineHeight
            self.errorUnderlineHeight = errorUnderlineHeight
            self.placeholderColor = placeholderColor
            self.cursorColor = cursorColor
            self.font = font
        }
        
        // MARK: - Functions that returns values depending on the view state
        
        func getBackgroundColor(for state: PinCodeItemViewState) -> UIColor {
            switch state {
            case .disabled:
                return defaultBackgroundColor
                
            case .active:
                return activeBackgroundColor ?? defaultBackgroundColor
                
            case .normal:
                return defaultBackgroundColor
                
            case .error:
                return errorBackgroundColor ?? defaultBackgroundColor
            }
        }
        
        func getUnderlineColor(for state: PinCodeItemViewState) -> UIColor {
            switch state {
            case .disabled:
                return defaultUnderlineColor
                
            case .active:
                return activeUnderlineColor ?? defaultUnderlineColor
                
            case .normal:
                return defaultUnderlineColor
                
            case .error:
                return errorUnderlineColor ?? defaultUnderlineColor
            }
        }
        
        func getUnderlineHeight(for state: PinCodeItemViewState) -> CGFloat {
            switch state {
            case .disabled:
                return defaultUnderlineHeight
                
            case .active:
                return activeUnderlineHeight ?? defaultUnderlineHeight
                
            case .normal:
                return defaultUnderlineHeight
                
            case .error:
                return errorUnderlineHeight ?? defaultUnderlineHeight
            }
        }
        
        func getTextColor(for state: PinCodeItemViewState) -> UIColor {
            switch state {
            case .disabled:
                return defaultValueColor
                
            case .active:
                return activeValueColor ?? defaultValueColor
                
            case .normal:
                return defaultValueColor
                
            case .error:
                return errorValueColor ?? defaultValueColor
            }
        }
    }
    
    // MARK: - Properties(public)
    
    public var viewState: PinCodeItemViewState = .normal {
        didSet {
            updateCursorPlaceholderVisibility()
            updateViewStateDependentAppearance()
        }
    }
    
    public var valueCharacter: Character? {
        didSet {
            updateCursorPlaceholderVisibility()
        }
    }
    
    public var placeholderCharacter: Character? {
        didSet {
            placeholderLabel.text = placeholderCharacter.flatMap({ $0 }).map({ String($0) })
        }
    }
    
    public var secureTextCharacter: Character?
    public var shouldSecureText: Bool = false
    public var secureTextDelay: TimeInterval = 2
    
    public var layoutConfig: LayoutConfig = LayoutConfig.defaultValue {
        didSet {
            resetConstants()
            configureView()
        }
    }
    
    public var appearanceConfig: AppearanceConfig = AppearanceConfig.defaultValue {
        didSet {
            updateConfigDependentAppearance()
            updateViewStateDependentAppearance()
        }
    }
    
    // MARK: - Properties(private)
    
    private var underlineViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var cursorView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        setupCursorAnimation()
        updateCursorPlaceholderVisibility()
        updateConfigDependentAppearance()
        updateViewStateDependentAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureView()
        setupCursorAnimation()
        updateCursorPlaceholderVisibility()
        updateConfigDependentAppearance()
        updateViewStateDependentAppearance()
    }
    
    // MARK: - Methods(public)
    
    // Animated - is only for secure value animation
    public func setCharacter(_ character: Character?, animated: Bool) {
        self.valueCharacter = character
        self.updateCursorPlaceholderVisibility()
        
        if shouldSecureText {
            if animated {
                contentLabel.text = valueCharacter.flatMap({ $0 }).map({ String($0) })
                DispatchQueue.main.asyncAfter(deadline: .now() + secureTextDelay) { [weak self] in
                    guard self?.valueCharacter != nil else {
                        return
                    }
                    
                    self?.contentLabel.text = self?.secureTextCharacter.flatMap({ $0 }).map({ String($0) })
                }
            }
            else {
                contentLabel.text = secureTextCharacter.flatMap({ $0 }).map({ String($0) })
            }
        }
        else {
            contentLabel.text = valueCharacter.flatMap({ $0 }).map({ String($0) })
        }
    }
    
    // MARK: - Methods(private)
    
    // Method that setups cursor blinking animation
    private func setupCursorAnimation() {
        UIView.animateKeyframes(
            withDuration: 1.6,
            delay: 0.8,
            options: [.repeat],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.2,
                    animations: {
                        self.cursorView.alpha = 0
                    })
                
                UIView.addKeyframe(
                    withRelativeStartTime: 0.8,
                    relativeDuration: 0.2,
                    animations: {
                        self.cursorView.alpha = 1
                    })
            },
            completion: nil
        )
    }
    
    private func updateCursorPlaceholderVisibility() {
        if viewState == .active {
            cursorView.isHidden = valueCharacter != nil
            contentLabel.isHidden = valueCharacter == nil
            placeholderLabel.isHidden = true
        }
        else {
            cursorView.isHidden = true
            contentLabel.isHidden = valueCharacter == nil
            placeholderLabel.isHidden = valueCharacter != nil
        }
    }
    
    private func updateConfigDependentAppearance() {
        contentLabel.font = appearanceConfig.font
        placeholderLabel.font = appearanceConfig.font
        cursorView.backgroundColor = appearanceConfig.cursorColor
        placeholderLabel.textColor = appearanceConfig.placeholderColor
    }
    
    private func updateViewStateDependentAppearance() {
        backgroundColor = appearanceConfig.getBackgroundColor(for: viewState)
        underlineViewHeightConstraint?.constant = appearanceConfig.getUnderlineHeight(for: viewState)
        underlineView.backgroundColor = appearanceConfig.getUnderlineColor(for: viewState)
        contentLabel.textColor = appearanceConfig.getTextColor(for: viewState)
    }
    
    // Method that resets all constratints that were added in the configure view method
    private func resetConstants() {
        NSLayoutConstraint.deactivate(cursorView.constraints)
        NSLayoutConstraint.deactivate(contentLabel.constraints)
        NSLayoutConstraint.deactivate(underlineView.constraints)
        NSLayoutConstraint.deactivate(placeholderLabel.constraints)

        underlineViewHeightConstraint = nil
    }
    
    // Main view configuration function, configuring whole view corner radius, layout etc
    private func configureView() {
        clipsToBounds = true
        layer.cornerRadius = layoutConfig.cornerRadius
        cursorView.layer.cornerRadius = layoutConfig.cursorCornerRadius
        
        addSubview(cursorView)
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cursorView.widthAnchor.constraint(equalToConstant: layoutConfig.cursorWidth),
            cursorView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: layoutConfig.cursorHeightMultiplier),
            cursorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cursorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addSubview(underlineView)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: appearanceConfig.getUnderlineHeight(for: viewState))
        ])
        
        addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: layoutConfig.contentLabelEdgeInsets.top),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutConfig.contentLabelEdgeInsets.left),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutConfig.contentLabelEdgeInsets.right),
            contentLabel.bottomAnchor.constraint(equalTo: underlineView.topAnchor, constant: layoutConfig.contentLabelEdgeInsets.bottom)
        ])
        
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: contentLabel.topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: contentLabel.bottomAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor)
        ])
    }
}
