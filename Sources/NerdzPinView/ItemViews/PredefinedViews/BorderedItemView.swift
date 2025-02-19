//
//  BorderedItemView.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

public final class BorderedItemView: PinTapableView, PinCodeItemViewType, ItemViewLayoutConfigurable, ItemViewAppearanceConfigurable {
    
    // MARK: - Internal types
    
    public struct LayoutConfig: DefaultableConfigType {
        public static let defaultValue: LayoutConfig = LayoutConfig()
        
        public var cursorCornerRadius: CGFloat
        public var cursorHeightMultiplier: CGFloat
        public var cursorWidth: CGFloat
        
        public var cornerRadius: CGFloat
        
        public var contentLabelEdgeInsets: UIEdgeInsets
        
        public init(
            cursorCornerRadius: CGFloat = 0.5,
            cursorHeightMultiplier: CGFloat = 0.7,
            cursorWidth: CGFloat = 1,
            cornerRadius: CGFloat = 8,
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
                
        public var defaultBorderColor: UIColor
        public var activeBorderColor: UIColor?
        public var errorBorderColor: UIColor?
        
        public var defaultBorderWidth: CGFloat
        public var activeBorderWidth: CGFloat?
        public var errorBorderWidth: CGFloat?
        
        public var placeholderColor: UIColor
        public var cursorColor: UIColor
        public var font: UIFont
        
        // MARK: - Life cycle
        
        public init(
            defaultBackgroundColor: UIColor = .white,
            activeBackgroundColor: UIColor? = nil,
            errorBackgroundColor: UIColor? = nil,
            defaultValueColor: UIColor = .black,
            activeValueColor: UIColor? = nil,
            errorValueColor: UIColor? = nil,
            placeholderColor: UIColor = .lightGray,
            defaultBorderColor: UIColor = .lightGray,
            activeBorderColor: UIColor? = .blue,
            errorBorderColor: UIColor? = .red,
            defaultBorderWidth: CGFloat = 1,
            activeBorderWidth: CGFloat? = nil,
            errorBorderWidth: CGFloat? = nil,
            cursorColor: UIColor = .red,
            font: UIFont = .systemFont(ofSize: 14)
        ) {
            self.defaultBackgroundColor = defaultBackgroundColor
            self.activeBackgroundColor = activeBackgroundColor
            self.errorBackgroundColor = errorBackgroundColor
            self.defaultValueColor = defaultValueColor
            self.activeValueColor = activeValueColor
            self.errorValueColor = errorValueColor
            self.placeholderColor = placeholderColor
            self.defaultBorderColor = defaultBorderColor
            self.activeBorderColor = activeBorderColor
            self.errorBorderColor = errorBorderColor
            self.defaultBorderWidth = defaultBorderWidth
            self.activeBorderWidth = activeBorderWidth
            self.errorBorderWidth = errorBorderWidth
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
        
        func getBorderColor(for state: PinCodeItemViewState) -> UIColor {
            switch state {
            case .disabled:
                return defaultBorderColor
                
            case .active:
                return activeBorderColor ?? defaultBorderColor
                
            case .normal:
                return defaultBorderColor
                
            case .error:
                return errorBorderColor ?? defaultBorderColor
            }
        }
        
        func getBorderWidth(for state: PinCodeItemViewState) -> CGFloat {
            switch state {
            case .disabled:
                return defaultBorderWidth
                
            case .active:
                return activeBorderWidth ?? defaultBorderWidth
                
            case .normal:
                return defaultBorderWidth
                
            case .error:
                return errorBorderWidth ?? defaultBorderWidth
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
    public var secureTextDelay: TimeInterval = .zero
    
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
                
    private lazy var cursorView: UIView = {
        let view = UIView()
        return view
    }()
        
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        setupCursorAnimation()
        updateCursorPlaceholderVisibility()
        updateConfigDependentAppearance()
        updateViewStateDependentAppearance()
    }
    
    required init?(coder: NSCoder) {
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
        layer.borderColor = appearanceConfig.getBorderColor(for: viewState).cgColor
        layer.borderWidth = appearanceConfig.getBorderWidth(for: viewState)
        contentLabel.textColor = appearanceConfig.getTextColor(for: viewState)
    }
    
    // Method that resets all constratints that were added in the configure view method
    private func resetConstants() {
        NSLayoutConstraint.deactivate(cursorView.constraints)
        NSLayoutConstraint.deactivate(contentLabel.constraints)
        NSLayoutConstraint.deactivate(placeholderLabel.constraints)
    }
    
    // Main view configuration function, configuring whole view corner radius, layout etc
    private func configureView() {
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
        
        addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: layoutConfig.contentLabelEdgeInsets.top),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutConfig.contentLabelEdgeInsets.bottom),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutConfig.contentLabelEdgeInsets.left),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutConfig.contentLabelEdgeInsets.right)
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
