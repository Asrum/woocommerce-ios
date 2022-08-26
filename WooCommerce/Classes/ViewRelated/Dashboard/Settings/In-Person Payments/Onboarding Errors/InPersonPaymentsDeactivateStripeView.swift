import SwiftUI
import Yosemite

struct InPersonPaymentsDeactivateStripeView: View {
    let analyticReason: String?
    let onRefresh: () -> Void
    let showSetupPluginsButton: Bool
    @State private var presentedSetupURL: URL? = nil

    var body: some View {
        ScrollableVStack {
            Spacer()

            InPersonPaymentsOnboardingErrorMainContentView(
                title: Localization.title,
                message: showSetupPluginsButton ? Localization.buttonMessage : Localization.message,
                image: InPersonPaymentsOnboardingErrorMainContentView.ImageInfo(
                    image: .paymentErrorImage,
                    height: Constants.height
                ),
                supportLink: false
            )

            InPersonPaymentsSupportLink()

            Spacer()

            if showSetupPluginsButton {
                Button {
                    presentedSetupURL = setupURL
                } label: {
                    HStack {
                        Text(Localization.primaryButton)
                        Image(uiImage: .externalImage)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, Constants.padding)
            }

            InPersonPaymentsLearnMore(analyticReason: analyticReason)
        }
        .safariSheet(url: $presentedSetupURL, onDismiss: onRefresh)
    }

    private var setupURL: URL? {
        guard let pluginsURL = ServiceLocator.stores.sessionManager.defaultSite?.pluginsURL else {
            return nil
        }

        return URL(string: pluginsURL)
    }
}

private enum Localization {
    static let title = NSLocalizedString(
        "In-Person Payments are processed through WooCommerce Payments.",
        comment: "Title for the error screen when there is more than one plugin active " +
        "and the Stripe plugin should be deactivated"
    )

    static let buttonMessage = NSLocalizedString(
        "To collect payments, please deactivate WooCommerce Stripe Gateway.",
        comment: "Message prompting an administrator to deactivate Stripe plugin"
    )

    static let message = NSLocalizedString(
        "To collect payments, please ask an administrator to deactivate WooCommerce Stripe Gateway.",
        comment: "Message prompting an administrator to deactivate Stripe plugin"
    )

    static let primaryButton = NSLocalizedString(
        "Manage Plugins",
        comment: "Button to open browser to manage plugins"
    )
}

private enum Constants {
    static let height: CGFloat = 108.0
    static let padding: CGFloat = 24.0
}

struct InPersonPaymentsDeactivateStripeAdmin_Previews: PreviewProvider {
    static var previews: some View {
        InPersonPaymentsPluginConflictAdmin(analyticReason: nil, onRefresh: {})
    }
}
