import UIKit

final class CardReaderSettingsConnectView: NSObject {

    private var rows = [Row]()

    var onPressedConnect: (() -> ())?

    override init() {
        super.init()
        rows = [
            .connectHeader,
            .connectImage,
            .connectHelpHintChargeReader,
            .connectHelpHintTurnOnReader,
            .connectHelpHintEnableBluetooth,
            .connectButton,
            .connectLearnMore
        ]
    }

    public func rowTypes() -> [UITableViewCell.Type] {
        return [
            ButtonTableViewCell.self,
            ImageTableViewCell.self,
            LearnMoreTableViewCell.self,
            NumberedListItemTableViewCell.self,
            TitleTableViewCell.self
        ]
    }

    private func configure(_ cell: UITableViewCell, for row: Row, at indexPath: IndexPath) {
        switch cell {
        case let cell as TitleTableViewCell where row == .connectHeader:
            configureHeader(cell: cell)
        case let cell as ImageTableViewCell where row == .connectImage:
            configureImage(cell: cell)
        case let cell as NumberedListItemTableViewCell where row == .connectHelpHintChargeReader:
            configureHelpHintChargeReader(cell: cell)
        case let cell as NumberedListItemTableViewCell where row == .connectHelpHintTurnOnReader:
            configureHelpHintTurnOnReader(cell: cell)
        case let cell as NumberedListItemTableViewCell where row == .connectHelpHintEnableBluetooth:
            configureHelpHintEnableBluetooth(cell: cell)
        case let cell as ButtonTableViewCell where row == .connectButton:
            configureButton(cell: cell)
        case let cell as LearnMoreTableViewCell where row == .connectLearnMore:
            configureLearnMore(cell: cell)
        default:
            fatalError()
        }
    }

    private func configureHeader(cell: TitleTableViewCell) {
        cell.titleLabel?.text = Localization.connectYourCardReaderTitle
        cell.selectionStyle = .none
    }

    private func configureImage(cell: ImageTableViewCell) {
        cell.detailImageView?.image = UIImage(named: "card-reader-connect")
        cell.selectionStyle = .none
    }

    private func configureHelpHintChargeReader(cell: NumberedListItemTableViewCell) {
        cell.numberLabel?.text = Localization.hintOneTitle
        cell.itemTextLabel?.text = Localization.hintOne
        cell.selectionStyle = .none
    }

    private func configureHelpHintTurnOnReader(cell: NumberedListItemTableViewCell) {
        cell.numberLabel?.text = Localization.hintTwoTitle
        cell.itemTextLabel?.text = Localization.hintTwo
        cell.selectionStyle = .none
    }

    private func configureHelpHintEnableBluetooth(cell: NumberedListItemTableViewCell) {
        cell.numberLabel?.text = Localization.hintThreeTitle
        cell.itemTextLabel?.text = Localization.hintThree
        cell.selectionStyle = .none
   }

    private func configureButton(cell: ButtonTableViewCell) {
        let buttonTitle = Localization.connectButton
        cell.configure(title: buttonTitle) { [weak self] in
            self?.onPressedConnect?()
        }
        cell.selectionStyle = .none
    }

    private func configureLearnMore(cell: LearnMoreTableViewCell) {
        cell.learnMoreTextView.text = Localization.learnMore
        cell.selectionStyle = .none
    }
}

private enum Row: CaseIterable {
    case connectHeader
    case connectImage
    case connectHelpHintChargeReader
    case connectHelpHintTurnOnReader
    case connectHelpHintEnableBluetooth
    case connectButton
    case connectLearnMore

    var type: UITableViewCell.Type {
        switch self {
        case .connectHeader:
            return TitleTableViewCell.self
        case .connectImage:
            return ImageTableViewCell.self
        case .connectHelpHintChargeReader:
            return NumberedListItemTableViewCell.self
        case .connectHelpHintTurnOnReader:
            return NumberedListItemTableViewCell.self
        case .connectHelpHintEnableBluetooth:
            return NumberedListItemTableViewCell.self
        case .connectButton:
            return ButtonTableViewCell.self
        case .connectLearnMore:
            return LearnMoreTableViewCell.self
        }
    }

    var height: CGFloat {
        switch self {
        case .connectHeader,
             .connectButton,
             .connectImage:
            return UITableView.automaticDimension
        case .connectHelpHintChargeReader,
             .connectHelpHintTurnOnReader,
             .connectHelpHintEnableBluetooth,
             .connectLearnMore:
            return 70
        }
    }

    var reuseIdentifier: String {
        return type.reuseIdentifier
    }
}

// MARK: - Convenience Methods
//
private extension CardReaderSettingsConnectView {
    func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
}

// MARK: - UITableViewDataSource Conformance
//
extension CardReaderSettingsConnectView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        configure(cell, for: row, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate Conformance
//
extension CardReaderSettingsConnectView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = rowAtIndexPath(indexPath)
        return row.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rowAtIndexPath(indexPath)
        if row == .connectLearnMore {
            guard let url = URL(string: "https://woocommerce.com/payments/") else {
                return
            }
            UIApplication.shared.open(url)
        }
    }
}

private enum Localization {
    static let connectYourCardReaderTitle = NSLocalizedString(
        "Connect your card reader",
        comment: "Settings > Manage Card Reader > Prompt user to connect their first reader"
    )

    static let hintOneTitle = NSLocalizedString(
        "1",
        comment: "Settings > Manage Card Reader > Connect > Help hint number 1"
    )

    static let hintOne = NSLocalizedString(
        "Make sure card reader is charged",
        comment: "Settings > Manage Card Reader > Connect > Hint to charge card reader"
    )

    static let hintTwoTitle = NSLocalizedString(
        "2",
        comment: "Settings > Manage Card Reader > Connect > Help hint number 2"
    )

    static let hintTwo = NSLocalizedString(
        "Turn card reader on and place it next to mobile device",
        comment: "Settings > Manage Card Reader > Connect > Hint to power on reader"
    )

    static let hintThreeTitle = NSLocalizedString(
        "3",
        comment: "Settings > Manage Card Reader > Connect > Help hint number 3"
    )

    static let hintThree = NSLocalizedString(
        "Turn mobile device Bluetooth on",
        comment: "Settings > Manage Card Reader > Connect > Hint to enable Bluetooth"
    )

    static let connectButton = NSLocalizedString(
        "Connect Card Reader",
        comment: "Settings > Manage Card Reader > Connect > A button to begin a search for a reader"
    )

    static let learnMore = NSLocalizedString(
        "Learn more about accepting payments with your mobile device and ordering card readers",
        comment: "Settings > Manage Card Reader > Connect > A prompt for new users to start accepting mobile payments"
    )
}
