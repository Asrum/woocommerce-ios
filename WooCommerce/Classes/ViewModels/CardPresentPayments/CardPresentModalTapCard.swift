import UIKit
import Yosemite

/// Modal presented when the card reader requests customers to tap/insert/swipe the card
final class CardPresentModalTapCard: CardPresentPaymentsModalViewModel {

    /// Customer name
    private let name: String

    /// Charge amount
    private let amount: String

    /// Cancellation callback
    private let onCancel: () -> Void

    let textMode: PaymentsModalTextMode = .fullInfo
    let actionsMode: PaymentsModalActionsMode = .secondaryOnlyAction

    var topTitle: String {
        name
    }

    var topSubtitle: String? {
        amount
    }

    let image: UIImage = .cardPresentImage

    let primaryButtonTitle: String? = nil

    let secondaryButtonTitle: String? = Localization.cancel

    let auxiliaryButtonTitle: String? = nil

    let bottomTitle: String? = Localization.readerIsReady

    let bottomSubtitle: String?

    let accessibilityLabel: String?

    init(name: String, amount: String, transactionType: CardPresentTransactionType, onCancel: @escaping () -> Void) {
        self.name = name
        self.amount = amount
        self.bottomSubtitle = Localization.tapInsertOrSwipe(transactionType: transactionType)
        self.accessibilityLabel = Localization.readerIsReady + Localization.tapInsertOrSwipe(transactionType: transactionType)
        self.onCancel = onCancel
    }

    func didTapPrimaryButton(in viewController: UIViewController?) {
        //
    }

    func didTapSecondaryButton(in viewController: UIViewController?) {
        viewController?.dismiss(animated: true, completion: { [weak self] in
            self?.onCancel()
        })
    }

    func didTapAuxiliaryButton(in viewController: UIViewController?) {
        //
    }
}

private extension CardPresentModalTapCard {
    enum Localization {
        static let readerIsReady = NSLocalizedString(
            "Reader is ready",
            comment: "Indicates the status of a card reader. Presented to users when payment collection starts"
        )

        static func tapInsertOrSwipe(transactionType: CardPresentTransactionType) -> String {
            switch transactionType {
            case .collectPayment:
                return NSLocalizedString(
                    "Tap, insert or swipe to pay",
                    comment: "Label asking users to present a card. Presented to users when a payment is going to be collected"
                )
            case .refund:
                return NSLocalizedString(
                    "Tap, insert or swipe to refund",
                    comment: "Label asking users to present a card. Presented to users when an in-person refund is going to be executed"
                )
            }
        }

        static let cancel = NSLocalizedString(
            "Cancel",
            comment: "Button to cancel a payment"
        )
    }
}
