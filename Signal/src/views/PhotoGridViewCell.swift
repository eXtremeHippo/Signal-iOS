//
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

import SignalUI
import UIKit

public enum PhotoGridItemType {
    case photo, animated, video
}

public protocol PhotoGridItem: AnyObject {
    var type: PhotoGridItemType { get }
    var duration: TimeInterval { get } // proxy to PHAsset.duration, always 0 for non-movie assets
    func asyncThumbnail(completion: @escaping (UIImage?) -> Void) -> UIImage?
}

public class PhotoGridViewCell: UICollectionViewCell {

    static let reuseIdentifier = "PhotoGridViewCell"

    public let imageView: UIImageView

    private var contentTypeBadgeView: UIImageView?
    private var durationLabel: UILabel?
    private var durationLabelBackground: UIView?
    private let outlineBadgeView: UIView
    private let selectedBadgeView: UIView

    private let highlightedMaskView: UIView
    private let selectedMaskView: UIView

    var item: PhotoGridItem?

    private static let animatedBadgeImage = #imageLiteral(resourceName: "ic_gallery_badge_gif")
    private static let selectedBadgeImage = UIImage(named: "media-composer-checkmark")
    public var loadingColor = Theme.washColor

    override public var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }

    public var allowsMultipleSelection: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    private func updateSelectionState() {
        if isSelected {
            outlineBadgeView.isHidden = false
            selectedBadgeView.isHidden = false
            selectedMaskView.isHidden = false
        } else if allowsMultipleSelection {
            outlineBadgeView.isHidden = false
            selectedBadgeView.isHidden = true
            selectedMaskView.isHidden = true
        } else {
            outlineBadgeView.isHidden = true
            selectedBadgeView.isHidden = true
            selectedMaskView.isHidden = true
        }
    }

    override public var isHighlighted: Bool {
        didSet {
            self.highlightedMaskView.isHidden = !self.isHighlighted
        }
    }

    override init(frame: CGRect) {
        let selectionBadgeSize: CGFloat = 22

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill

        selectedBadgeView = CircleView(diameter: selectionBadgeSize)
        selectedBadgeView.backgroundColor = .ows_accentBlue
        selectedBadgeView.isHidden = true
        let checkmarkImageView = UIImageView(image: PhotoGridViewCell.selectedBadgeImage)
        checkmarkImageView.tintColor = .white
        selectedBadgeView.addSubview(checkmarkImageView)
        checkmarkImageView.autoCenterInSuperview()

        outlineBadgeView = CircleView()
        outlineBadgeView.backgroundColor = .clear
        outlineBadgeView.layer.borderWidth = 1.5
        outlineBadgeView.layer.borderColor = UIColor.ows_white.cgColor
        selectedBadgeView.isHidden = true

        highlightedMaskView = UIView()
        highlightedMaskView.alpha = 0.2
        highlightedMaskView.backgroundColor = Theme.darkThemePrimaryColor
        highlightedMaskView.isHidden = true

        selectedMaskView = UIView()
        selectedMaskView.alpha = 0.3
        selectedMaskView.backgroundColor = Theme.darkThemeBackgroundColor
        selectedMaskView.isHidden = true

        super.init(frame: frame)

        clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(highlightedMaskView)
        contentView.addSubview(selectedMaskView)
        contentView.addSubview(selectedBadgeView)
        contentView.addSubview(outlineBadgeView)

        imageView.autoPinEdgesToSuperviewEdges()
        highlightedMaskView.autoPinEdgesToSuperviewEdges()
        selectedMaskView.autoPinEdgesToSuperviewEdges()

        outlineBadgeView.autoSetDimensions(to: CGSize(square: selectionBadgeSize))
        outlineBadgeView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 6)
        outlineBadgeView.autoPinEdge(toSuperviewEdge: .top, withInset: 6)

        selectedBadgeView.autoSetDimensions(to: CGSize(square: selectionBadgeSize))
        selectedBadgeView.autoAlignAxis(.vertical, toSameAxisOf: outlineBadgeView)
        selectedBadgeView.autoAlignAxis(.horizontal, toSameAxisOf: outlineBadgeView)
    }

    @available(*, unavailable, message: "Unimplemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if let durationLabel = durationLabel {
            durationLabel.font = .ows_dynamicTypeCaption1.ows_semibold
        }
    }

    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.backgroundColor = newValue == nil ? loadingColor : .clear
        }
    }

    private func setContentTypeBadge(image: UIImage?) {
        guard image != nil else {
            contentTypeBadgeView?.isHidden = true
            return
        }

        if contentTypeBadgeView == nil {
            let contentTypeBadgeView = UIImageView()
            contentView.addSubview(contentTypeBadgeView)
            contentTypeBadgeView.autoPinEdge(toSuperviewEdge: .leading, withInset: 4)
            contentTypeBadgeView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 4)
            self.contentTypeBadgeView = contentTypeBadgeView
        }
        contentTypeBadgeView?.isHidden = false
        contentTypeBadgeView?.image = image
        contentTypeBadgeView?.sizeToFit()
    }

    private func setMedia(duration: TimeInterval) {
        guard duration > 0 else {
            durationLabel?.isHidden = true
            durationLabelBackground?.isHidden = true
            return
        }

        if durationLabel == nil {
            let durationLabel = UILabel()
            durationLabel.textColor = .ows_gray05
            durationLabel.font = .ows_dynamicTypeCaption1.ows_semibold
            durationLabel.layer.shadowColor = UIColor.ows_blackAlpha20.cgColor
            durationLabel.layer.shadowOffset = CGSize(width: -1, height: -1)
            durationLabel.layer.shadowOpacity = 1
            durationLabel.layer.shadowRadius = 4
            durationLabel.shadowOffset = CGSize(width: 0, height: 1)
            durationLabel.adjustsFontForContentSizeCategory = true
            self.durationLabel = durationLabel
        }
        if durationLabelBackground == nil {
            let gradientView = GradientView(from: .ows_blackAlpha40, to: .clear)
            gradientView.gradientLayer.type = .radial
            gradientView.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradientView.gradientLayer.endPoint = CGPoint(x: 0, y: 90/122) // 122 x 58 oval
            self.durationLabelBackground = gradientView
        }

        guard let durationLabel = durationLabel, let durationLabelBackground = durationLabelBackground else {
            return
        }

        if durationLabel.superview == nil {
            contentView.addSubview(durationLabel)
            durationLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 6)
            durationLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 4)
        }
        if durationLabelBackground.superview == nil {
            contentView.insertSubview(durationLabelBackground, belowSubview: durationLabel)
            durationLabelBackground.autoPinEdge(.top, to: .top, of: durationLabel, withOffset: -10)
            durationLabelBackground.autoPinEdge(.leading, to: .leading, of: durationLabel, withOffset: -24)
            durationLabelBackground.centerXAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            durationLabelBackground.centerYAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }

        durationLabel.isHidden = false
        durationLabelBackground.isHidden = false
        durationLabel.text = OWSFormat.localizedDurationString(from: duration)
        durationLabel.sizeToFit()
    }

    public func configure(item: PhotoGridItem) {
        self.item = item

        // PHCachingImageManager returns multiple progressively better
        // thumbnails in the async block. We want to avoid calling
        // `configure(item:)` multiple times because the high-quality image eventually applied
        // last time it was called will be momentarily replaced by a progression of lower
        // quality images.
        image = item.asyncThumbnail { [weak self] image in
            guard let self = self else { return }

            guard let currentItem = self.item else {
                return
            }

            guard currentItem === item else {
                return
            }

            if image == nil {
                Logger.debug("image == nil")
            }
            self.image = image
        }

        setMedia(duration: item.duration)

        switch item.type {
        case .animated:
            setContentTypeBadge(image: PhotoGridViewCell.animatedBadgeImage)
        case .photo, .video:
            setContentTypeBadge(image: nil)
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        item = nil
        imageView.image = nil
        contentTypeBadgeView?.isHidden = true
        durationLabel?.isHidden = true
        durationLabelBackground?.isHidden = true
        highlightedMaskView.isHidden = true
        selectedMaskView.isHidden = true
        selectedBadgeView.isHidden = true
        outlineBadgeView.isHidden = true
    }
}
