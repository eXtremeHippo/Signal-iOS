//
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc
public class MessageAction: NSObject {
    @objc
    let block: (_ sender: Any?) -> Void
    let accessibilityIdentifier: String
    let contextMenuTitle: String
    let contextMenuAttributes: ContextMenuAction.Attributes

    public enum MessageActionType {
        case reply
        case copy
        case info
        case delete
        case share
        case forward
        case select
    }

    let actionType: MessageActionType

    public init(_ actionType: MessageActionType,
                accessibilityLabel: String,
                accessibilityIdentifier: String,
                contextMenuTitle: String,
                contextMenuAttributes: ContextMenuAction.Attributes,
                block: @escaping (_ sender: Any?) -> Void) {
        self.actionType = actionType
        self.accessibilityIdentifier = accessibilityIdentifier
        self.contextMenuTitle = contextMenuTitle
        self.contextMenuAttributes = contextMenuAttributes
        self.block = block
        super.init()
        self.accessibilityLabel = accessibilityLabel
    }

    var image: UIImage {
        switch actionType {
        case .reply:
            return Theme.iconImage(.messageActionReply)
        case .copy:
            return Theme.iconImage(.messageActionCopy)
        case .info:
            return Theme.iconImage(.contextMenuInfo)
        case .delete:
            return Theme.iconImage(.messageActionDelete)
        case .share:
            return Theme.iconImage(.messageActionShare)
        case .forward:
            return Theme.iconImage(.messageActionForward)
        case .select:
            return Theme.iconImage(.contextMenuSelect)
        }
    }
}

public protocol MessageActionsToolbarDelegate: AnyObject {
    func messageActionsToolbar(_ messageActionsToolbar: MessageActionsToolbar, executedAction: MessageAction)
    var messageActionsToolbarSelectedInteractionCount: Int { get }
}

public class MessageActionsToolbar: UIToolbar {

    weak var actionDelegate: MessageActionsToolbarDelegate?

    enum Mode {
        case normal(messagesActions: [MessageAction])
        case selection(deleteMessagesAction: MessageAction,
                       forwardMessagesAction: MessageAction)
    }
    private let mode: Mode

    deinit {
        Logger.verbose("")
    }

    required init(mode: Mode) {
        self.mode = mode

        super.init(frame: .zero)

        isTranslucent = false
        isOpaque = true

        autoresizingMask = .flexibleHeight
        translatesAutoresizingMaskIntoConstraints = false
        setShadowImage(UIImage(), forToolbarPosition: .any)

        buildItems()

        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    @objc
    private func applyTheme() {
        AssertIsOnMainThread()

        barTintColor = Theme.isDarkThemeEnabled ? .ows_gray75 : .ows_white

        buildItems()
    }

    public func updateContent() {
        buildItems()
    }

    private func buildItems() {
        switch mode {
        case .normal(let messagesActions):
            buildNormalItems(messagesActions: messagesActions)
        case .selection(let deleteMessagesAction, let forwardMessagesAction):
            buildSelectionItems(deleteMessagesAction: deleteMessagesAction,
                                forwardMessagesAction: forwardMessagesAction)
        }
    }

    var actionItems = [MessageActionsToolbarButton]()

    private func buildNormalItems(messagesActions: [MessageAction]) {
        var newItems = [UIBarButtonItem]()

        var actionItems = [MessageActionsToolbarButton]()
        for action in messagesActions {
            if !newItems.isEmpty {
                newItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            }

            let actionItem = MessageActionsToolbarButton(actionsToolbar: self, messageAction: action)
            actionItem.tintColor = Theme.primaryIconColor
            actionItem.accessibilityLabel = action.accessibilityLabel
            newItems.append(actionItem)
            actionItems.append(actionItem)
        }

        // If we only have a single button, center it.
        if newItems.count == 1 {
            newItems.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: 0)
            newItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }

        items = newItems
        self.actionItems = actionItems
    }

    private func buildSelectionItems(deleteMessagesAction: MessageAction,
                                     forwardMessagesAction: MessageAction) {

        let deleteItem = MessageActionsToolbarButton(actionsToolbar: self, messageAction: deleteMessagesAction)
        let forwardItem = MessageActionsToolbarButton(actionsToolbar: self, messageAction: forwardMessagesAction)

        let selectedCount: Int = actionDelegate?.messageActionsToolbarSelectedInteractionCount ?? 0
        let labelTitle: String
        if selectedCount == 0 {
            labelTitle = NSLocalizedString("MESSAGE_ACTIONS_TOOLBAR_LABEL_0",
                                           comment: "Label for the toolbar used in the multi-select mode of conversation view when 0 items are selected.")
        } else if selectedCount == 1 {
            labelTitle = NSLocalizedString("MESSAGE_ACTIONS_TOOLBAR_LABEL_1",
                                           comment: "Label for the toolbar used in the multi-select mode of conversation view when 1 item is selected.")
        } else {
            let labelFormat = NSLocalizedString("MESSAGE_ACTIONS_TOOLBAR_LABEL_N_FORMAT",
                                                comment: "Format for the toolbar used in the multi-select mode of conversation view. Embeds: {{ %@ the number of currently selected items }}.")
            labelTitle = String(format: labelFormat, OWSFormat.formatInt(selectedCount))
        }
        let label = UILabel()
        label.text = labelTitle
        label.font = UIFont.ows_dynamicTypeBodyClamped
        label.textColor = Theme.primaryTextColor
        label.sizeToFit()
        let labelItem = UIBarButtonItem(customView: label)

        var newItems = [UIBarButtonItem]()
        newItems.append(deleteItem)
        newItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        newItems.append(labelItem)
        newItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        newItems.append(forwardItem)

        items = newItems
        self.actionItems = [ deleteItem, forwardItem ]
    }

    public func buttonItem(for actionType: MessageAction.MessageActionType) -> UIBarButtonItem? {
        for actionItem in actionItems {
            if let messageAction = actionItem.messageAction,
               messageAction.actionType == actionType {
                return actionItem
            }
        }
        owsFailDebug("Missing action item: \(actionType).")
        return nil
    }
}

// MARK: -

class MessageActionsToolbarButton: UIBarButtonItem {
    private weak var actionsToolbar: MessageActionsToolbar?
    fileprivate var messageAction: MessageAction?

    required override init() {
        super.init()
    }

    required init(actionsToolbar: MessageActionsToolbar, messageAction: MessageAction) {
        self.actionsToolbar = actionsToolbar
        self.messageAction = messageAction

        super.init()

        self.image = messageAction.image.withRenderingMode(.alwaysTemplate)
        self.style = .plain
        self.target = self
        self.action = #selector(didTapItem(_:))
        self.tintColor = Theme.primaryIconColor
        self.accessibilityLabel = messageAction.accessibilityLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func didTapItem(_ item: UIBarButtonItem) {
        AssertIsOnMainThread()

        guard let messageAction = messageAction,
              let actionsToolbar = actionsToolbar,
              let actionDelegate = actionsToolbar.actionDelegate else {
            return
        }
        actionDelegate.messageActionsToolbar(actionsToolbar, executedAction: messageAction)
    }
}
