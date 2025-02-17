//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved. test test
//

import Foundation

@objc
protocol MessageActionsDelegate: AnyObject {
    func messageActionsShowDetailsForItem(_ itemViewModel: CVItemViewModelImpl)
    func messageActionsReplyToItem(_ itemViewModel: CVItemViewModelImpl)
    func messageActionsForwardItem(_ itemViewModel: CVItemViewModelImpl)
    func messageActionsStartedSelect(initialItem itemViewModel: CVItemViewModelImpl)
    func messageActionsDeleteItem(_ itemViewModel: CVItemViewModelImpl)
}

// MARK: -

struct MessageActionBuilder {
    static func reply(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> MessageAction {
        return MessageAction(.reply,
                             accessibilityLabel: NSLocalizedString("MESSAGE_ACTION_REPLY", comment: "Action sheet button title"),
                             accessibilityIdentifier: UIView.accessibilityIdentifier(containerName: "message_action", name: "reply"),
                             contextMenuTitle: NSLocalizedString("CONTEXT_MENU_REPLY", comment: "Context menu button title"),
                             contextMenuAttributes: [],
                             block: { [weak delegate] (_) in
                                delegate?.messageActionsReplyToItem(itemViewModel)

        })
    }

    static func copyText(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> MessageAction {
        return MessageAction(.copy,
                             accessibilityLabel: NSLocalizedString("MESSAGE_ACTION_COPY_TEXT", comment: "Action sheet button title"),
                             accessibilityIdentifier: UIView.accessibilityIdentifier(containerName: "message_action", name: "copy_text"),
                             contextMenuTitle: NSLocalizedString("CONTEXT_MENU_COPY", comment: "Context menu button title"),
                             contextMenuAttributes: [],
                             block: { (_) in
                                itemViewModel.copyTextAction()
        })
    }

    static func showDetails(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> MessageAction {
        return MessageAction(.info,
                             accessibilityLabel: NSLocalizedString("MESSAGE_ACTION_DETAILS", comment: "Action sheet button title"),
                             accessibilityIdentifier: UIView.accessibilityIdentifier(containerName: "message_action", name: "show_details"),
                             contextMenuTitle: NSLocalizedString("CONTEXT_MENU_DETAILS", comment: "Context menu button title"),
                             contextMenuAttributes: [],
                             block: { [weak delegate] (_) in
                                delegate?.messageActionsShowDetailsForItem(itemViewModel)
        })
    }

    static func deleteMessage(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> MessageAction {
        return MessageAction(.delete,
                             accessibilityLabel: NSLocalizedString("MESSAGE_ACTION_DELETE_MESSAGE", comment: "Action sheet button title"),
                             accessibilityIdentifier: UIView.accessibilityIdentifier(containerName: "message_action", name: "delete_message"),
                             contextMenuTitle: NSLocalizedString("CONTEXT_MENU_DELETE_MESSAGE", comment: "Context menu button title"),
                             contextMenuAttributes: [.destructive],
                             block: { [weak delegate] (_) in
                                delegate?.messageActionsDeleteItem(itemViewModel)
        })
    }

    static func shareMedia(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> MessageAction {
        return MessageAction(.share,
                             accessibilityLabel: NSLocalizedString("MESSAGE_ACTION_SHARE_MEDIA", comment: "Action sheet button title"),
                             accessibilityIdentifier: UIView.accessibilityIdentifier(containerName: "message_action", name: "share_media"),
                             contextMenuTitle: NSLocalizedString("CONTEXT_MENU_SHARE_MEDIA", comment: "Context menu button title"),
                             contextMenuAttributes: [],
                             block: { sender in
                                itemViewModel.shareMediaAction(sender: sender)
        })
    }

    static func forwardMessage(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> MessageAction {
        return MessageAction(.forward,
                             accessibilityLabel: NSLocalizedString("MESSAGE_ACTION_FORWARD_MESSAGE", comment: "Action sheet button title"),
                             accessibilityIdentifier: UIView.accessibilityIdentifier(containerName: "message_action", name: "forward_message"),
                             contextMenuTitle: NSLocalizedString("CONTEXT_MENU_FORWARD_MESSAGE", comment: "Context menu button title"),
                             contextMenuAttributes: [],
                             block: { [weak delegate] (_) in
                                delegate?.messageActionsForwardItem(itemViewModel)
        })
    }

    static func selectMessage(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> MessageAction {
        return MessageAction(.select,
                             accessibilityLabel: NSLocalizedString("MESSAGE_ACTION_SELECT_MESSAGE", comment: "Action sheet accessibility label"),
                             accessibilityIdentifier: UIView.accessibilityIdentifier(containerName: "message_action", name: "select_message"),
                             contextMenuTitle: NSLocalizedString("CONTEXT_MENU_SELECT_MESSAGE", comment: "Context menu button title"),
                             contextMenuAttributes: [],
                             block: { [weak delegate] (_) in
                                delegate?.messageActionsStartedSelect(initialItem: itemViewModel)
        })
    }
}

@objc
class MessageActions: NSObject {

    @objc
    class func textActions(itemViewModel: CVItemViewModelImpl, shouldAllowReply: Bool, delegate: MessageActionsDelegate) -> [MessageAction] {
        var actions: [MessageAction] = []

        let showDetailsAction = MessageActionBuilder.showDetails(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(showDetailsAction)

        let deleteAction = MessageActionBuilder.deleteMessage(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(deleteAction)

        if itemViewModel.canCopyOrShareText {
            let copyTextAction = MessageActionBuilder.copyText(itemViewModel: itemViewModel, delegate: delegate)
            actions.append(copyTextAction)
        }

        if shouldAllowReply {
            let replyAction = MessageActionBuilder.reply(itemViewModel: itemViewModel, delegate: delegate)
            actions.append(replyAction)
        }

        if itemViewModel.canForwardMessage {
            actions.append(MessageActionBuilder.forwardMessage(itemViewModel: itemViewModel, delegate: delegate))
        }

        let selectAction = MessageActionBuilder.selectMessage(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(selectAction)

        return actions
    }

    @objc
    class func mediaActions(itemViewModel: CVItemViewModelImpl, shouldAllowReply: Bool, delegate: MessageActionsDelegate) -> [MessageAction] {
        var actions: [MessageAction] = []

        let showDetailsAction = MessageActionBuilder.showDetails(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(showDetailsAction)

        let deleteAction = MessageActionBuilder.deleteMessage(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(deleteAction)

        if itemViewModel.canShareMedia {
            let shareMediaAction = MessageActionBuilder.shareMedia(itemViewModel: itemViewModel, delegate: delegate)
            actions.append(shareMediaAction)
        }

        if shouldAllowReply {
            let replyAction = MessageActionBuilder.reply(itemViewModel: itemViewModel, delegate: delegate)
            actions.append(replyAction)
        }

        if itemViewModel.canForwardMessage {
            actions.append(MessageActionBuilder.forwardMessage(itemViewModel: itemViewModel, delegate: delegate))
        }

        let selectAction = MessageActionBuilder.selectMessage(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(selectAction)

        return actions
    }

    @objc
    class func quotedMessageActions(itemViewModel: CVItemViewModelImpl, shouldAllowReply: Bool, delegate: MessageActionsDelegate) -> [MessageAction] {
        var actions: [MessageAction] = []

        let showDetailsAction = MessageActionBuilder.showDetails(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(showDetailsAction)

        let deleteAction = MessageActionBuilder.deleteMessage(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(deleteAction)

        if shouldAllowReply {
            let replyAction = MessageActionBuilder.reply(itemViewModel: itemViewModel, delegate: delegate)
            actions.append(replyAction)
        }

        if itemViewModel.canForwardMessage {
            actions.append(MessageActionBuilder.forwardMessage(itemViewModel: itemViewModel, delegate: delegate))
        }

        let selectAction = MessageActionBuilder.selectMessage(itemViewModel: itemViewModel, delegate: delegate)
        actions.append(selectAction)

        return actions
    }

    @objc
    class func infoMessageActions(itemViewModel: CVItemViewModelImpl, delegate: MessageActionsDelegate) -> [MessageAction] {
        let deleteAction = MessageActionBuilder.deleteMessage(itemViewModel: itemViewModel, delegate: delegate)
        let selectAction = MessageActionBuilder.selectMessage(itemViewModel: itemViewModel, delegate: delegate)
        return [deleteAction, selectAction]
    }
}
