import SwiftUI

/// View showing a list of product variations to select.
///
struct ProductVariationSelector: View {
    @Environment(\.presentationMode) private var presentation

    /// Defines whether the view is presented.
    ///
    @Binding var isPresented: Bool

    /// View model to drive the view.
    ///
    @ObservedObject private var viewModel: ProductVariationSelectorViewModel

    /// Whether more than one row can be selected.
    ///
    private let multipleSelectionsEnabled: Bool

    private let onMultipleSelections: (([Int64]) -> Void)?

    ///   Environment safe areas
    ///
    @Environment(\.safeAreaInsets) private var safeAreaInsets: EdgeInsets

    init(isPresented: Binding<Bool>,
         viewModel: ProductVariationSelectorViewModel,
         multipleSelectionsEnabled: Bool = false,
         onMultipleSelections: (([Int64]) -> Void)? = nil) {
        self._isPresented = isPresented
        self.viewModel = viewModel
        self.multipleSelectionsEnabled = multipleSelectionsEnabled
        self.onMultipleSelections = onMultipleSelections
    }

    var body: some View {
        Group {
            switch viewModel.syncStatus {
            case .results:
                VStack(alignment: .leading, spacing: 0) {
                    Button(Localization.clearSelection) {
                        viewModel.clearSelection()
                    }
                    .buttonStyle(LinkButtonStyle())
                    .fixedSize()
                    .renderedIf(viewModel.selectedProductVariationIDs.isNotEmpty)

                    InfiniteScrollList(isLoading: viewModel.shouldShowScrollIndicator,
                                       loadAction: viewModel.syncNextPage) {
                        ForEach(viewModel.productVariationRows) { rowViewModel in
                            ProductRow(multipleSelectionsEnabled: multipleSelectionsEnabled,
                                       viewModel: rowViewModel)
                                .accessibilityHint(Localization.productRowAccessibilityHint)
                                .padding(Constants.defaultPadding)
                                .onTapGesture {
                                    viewModel.selectVariation(rowViewModel.productOrVariationID)
                                    if !multipleSelectionsEnabled {
                                        isPresented.toggle()
                                    }
                                }
                            Divider().frame(height: Constants.dividerHeight)
                                .padding(.leading, Constants.defaultPadding)
                        }
                    }
                }
                .padding(.horizontal, insets: safeAreaInsets)
                .background(Color(.listForeground).ignoresSafeArea())
            case .empty:
                EmptyState(title: Localization.emptyStateMessage, image: .emptyProductsTabImage)
                    .frame(maxHeight: .infinity)
            case .firstPageSync:
                List(viewModel.ghostRows) { rowViewModel in
                    ProductRow(viewModel: rowViewModel)
                        .redacted(reason: .placeholder)
                        .accessibilityRemoveTraits(.isButton)
                        .accessibilityLabel(Localization.loadingRowsAccessibilityLabel)
                        .shimmering()
                }
                .padding(.horizontal, insets: safeAreaInsets)
                .listStyle(PlainListStyle())
            default:
                EmptyView()
            }
        }
        .background(Color(.listBackground).ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .horizontal)
        .navigationTitle(viewModel.productName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Minimal back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentation.wrappedValue.dismiss()
                } label: {
                    Image(uiImage: .chevronLeftImage).flipsForRightToLeftLayoutDirection(true)
                }
                .accessibilityLabel(Localization.backButtonAccessibilityLabel)
            }
        }
        .onAppear {
            viewModel.onLoadTrigger.send()
        }
        .onDisappear {
            guard multipleSelectionsEnabled else {
                return
            }
            onMultipleSelections?(viewModel.selectedProductVariationIDs)
        }
        .notice($viewModel.notice, autoDismiss: false)
    }
}

private extension ProductVariationSelector {
    enum Constants {
        static let dividerHeight: CGFloat = 1
        static let defaultPadding: CGFloat = 16
    }

    enum Localization {
        static let emptyStateMessage = NSLocalizedString("No product variations found",
                                                         comment: "Message displayed if there are no product variations for a product.")

        static let backButtonAccessibilityLabel = NSLocalizedString("Back", comment: "Accessibility label for Back button in the navigation bar")
        static let productRowAccessibilityHint = NSLocalizedString("Adds variation to order.",
                                                                   comment: "Accessibility hint for selecting a variation in a list of product variations")
        static let loadingRowsAccessibilityLabel = NSLocalizedString("Loading product variations",
                                                                     comment: "Accessibility label for placeholder rows while product variations are loading")
        static let clearSelection = NSLocalizedString("Clear selection", comment: "Button to clear selection on the Select Product Variations screen")
    }
}

struct AddProductVariationToOrder_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ProductVariationSelectorViewModel(
            siteID: 1,
            productID: 2,
            productName: "Monstera Plant",
            productAttributes: [],
            selectedProductVariationIDs: []
        )

        ProductVariationSelector(isPresented: .constant(true), viewModel: viewModel, multipleSelectionsEnabled: true)
    }
}
