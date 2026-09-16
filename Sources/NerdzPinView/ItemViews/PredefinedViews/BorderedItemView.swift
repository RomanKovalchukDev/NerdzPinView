//
//  BorderedItemView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

/// A pin item view that draws each character inside a rounded rectangle with a border.
///
/// Use it as the item type of a ``PinCodeInputView``. Its appearance and layout
/// are driven by ``AppearanceConfig`` and ``LayoutConfig``, and it supports a
/// blinking cursor, a placeholder, and secure text masking.
public final class BorderedItemView: PinTapableView, PinCodeItemViewType, ItemViewLayoutConfigurable, ItemViewAppearanceConfigurable {

    // MARK: - Internal types

    /// Layout values that control the size and geometry of a ``BorderedItemView``.
    public struct LayoutConfig: DefaultableConfigType {
        /// The default layout applied when no custom value is provided.
        public static let defaultValue: LayoutConfig = LayoutConfig()

        /// The corner radius of the blinking cursor.
        public var cursorCornerRadius: CGFloat

        /// The cursor height as a fraction of the item height.
        public var cursorHeightMultiplier: CGFloat

        /// The width of the blinking cursor.
        public var cursorWidth: CGFloat

        /// The corner radius of the item's rounded rectangle.
        public var cornerRadius: CGFloat

        /// The insets applied around the character label.
        public var contentLabelEdgeInsets: UIEdgeInsets

        /// Creates a layout configuration.
        ///
        /// - Parameters:
        ///   - cursorCornerRadius: The corner radius of the blinking cursor.
        ///   - cursorHeightMultiplier: The cursor height as a fraction of the item height.
        ///   - cursorWidth: The width of the blinking cursor.
        ///   - cornerRadius: The corner radius of the item's rounded rectangle.
        ///   - contentLabelEdgeInsets: The insets applied around the character label.
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
    
    /// Colors, border widths, and fonts that control the look of a ``BorderedItemView``.
    ///
    /// State specific values are optional. When a value for the active or error
    /// state is `nil`, the corresponding default value is used instead.
    public struct AppearanceConfig: DefaultableConfigType {

        /// The default appearance applied when no custom value is provided.
        public static let defaultValue: AppearanceConfig = AppearanceConfig()

        /// The background color used in the normal and disabled states.
        public var defaultBackgroundColor: UIColor

        /// The background color used in the active state, or `nil` to reuse the default.
        public var activeBackgroundColor: UIColor?

        /// The background color used in the error state, or `nil` to reuse the default.
        public var errorBackgroundColor: UIColor?

        /// The character color used in the normal and disabled states.
        public var defaultValueColor: UIColor

        /// The character color used in the active state, or `nil` to reuse the default.
        public var activeValueColor: UIColor?

        /// The character color used in the error state, or `nil` to reuse the default.
        public var errorValueColor: UIColor?

        /// The border color used in the normal and disabled states.
        public var defaultBorderColor: UIColor

        /// The border color used in the active state, or `nil` to reuse the default.
        public var activeBorderColor: UIColor?

        /// The border color used in the error state, or `nil` to reuse the default.
        public var errorBorderColor: UIColor?

        /// The border width used in the normal and disabled states.
        public var defaultBorderWidth: CGFloat

        /// The border width used in the active state, or `nil` to reuse the default.
        public var activeBorderWidth: CGFloat?

        /// The border width used in the error state, or `nil` to reuse the default.
        public var errorBorderWidth: CGFloat?

        /// The color of the placeholder character.
        public var placeholderColor: UIColor

        /// The color of the blinking cursor.
        public var cursorColor: UIColor

        /// The font used for the character and placeholder labels.
        public var font: UIFont

        // MARK: - Life cycle

        /// Creates an appearance configuration.
        ///
        /// - Parameters:
        ///   - defaultBackgroundColor: The background color for the normal and disabled states.
        ///   - activeBackgroundColor: The background color for the active state, or `nil` to reuse the default.
        ///   - errorBackgroundColor: The background color for the error state, or `nil` to reuse the default.
        ///   - defaultValueColor: The character color for the normal and disabled states.
        ///   - activeValueColor: The character color for the active state, or `nil` to reuse the default.
        ///   - errorValueColor: The character color for the error state, or `nil` to reuse the default.
        ///   - placeholderColor: The color of the placeholder character.
        ///   - defaultBorderColor: The border color for the normal and disabled states.
        ///   - activeBorderColor: The border color for the active state, or `nil` to reuse the default.
        ///   - errorBorderColor: The border color for the error state, or `nil` to reuse the default.
        ///   - defaultBorderWidth: The border width for the normal and disabled states.
        ///   - activeBorderWidth: The border width for the active state, or `nil` to reuse the default.
        ///   - errorBorderWidth: The border width for the error state, or `nil` to reuse the default.
        ///   - cursorColor: The color of the blinking cursor.
        ///   - font: The font used for the character and placeholder labels.
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

    /// The current visual state that drives colors, border, and cursor visibility.
    public var viewState: PinCodeItemViewState = .normal {
        didSet {
            updateCursorPlaceholderVisibility()
            updateViewStateDependentAppearance()
        }
    }

    /// The character currently shown in the item, or `nil` when the item is empty.
    public var valueCharacter: Character? {
        didSet {
            updateCursorPlaceholderVisibility()
        }
    }

    /// The placeholder character shown while the item has no value.
    public var placeholderCharacter: Character? {
        didSet {
            placeholderLabel.text = placeholderCharacter.flatMap({ $0 }).map({ String($0) })
        }
    }

    /// The character substituted for the real value when secure entry is on.
    public var secureTextCharacter: Character?

    /// A Boolean value indicating whether the real value is masked by the secure character.
    public var shouldSecureText: Bool = false

    /// The delay before the visible character is replaced by the secure character.
    public var secureTextDelay: TimeInterval = .zero

    /// The layout configuration currently applied to the item view.
    public var layoutConfig: LayoutConfig = LayoutConfig.defaultValue {
        didSet {
            resetConstants()
            configureView()
        }
    }

    /// The appearance configuration currently applied to the item view.
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
    
    /// Sets the displayed character, optionally animating the transition to the secure character.
    ///
    /// - Parameters:
    ///   - character: The character to display, or `nil` to clear the item.
    ///   - animated: Whether to briefly show the real character before masking it. Only relevant when secure entry is on.
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
