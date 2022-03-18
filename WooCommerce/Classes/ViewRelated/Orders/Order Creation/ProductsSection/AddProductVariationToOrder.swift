import SwiftUI

/// View showing a list of product variations to add to an order.
///
struct AddProductVariationToOrder: View {
    @Environment(\.presentationMode) private var presentation

    /// Defines whether the view is presented.
    ///
    @Binding var isPresented: Bool

    /// View model to drive the view.
    ///
    @ObservedObject var viewModel: AddProductVariationToOrderViewModel

    var body: some View {
        Group {
            switch viewModel.syncStatus {
            case .results:
                InfiniteScrollList(isLoading: viewModel.shouldShowScrollIndicator,
                                   loadAction: viewModel.syncNextPage) {
                    ForEach(viewModel.productVariationRows) { rowViewModel in
                        ProductRow(viewModel: rowViewModel)
                            .padding(Constants.defaultPadding)
                            .onTapGesture {
                                viewModel.selectVariation(rowViewModel.productOrVariationID)
                                isPresented.toggle()
                            }
                        Divider().frame(height: Constants.dividerHeight)
                            .padding(.leading, Constants.defaultPadding)
                    }
                    .background(Color(.listForeground))
                }
            case .empty:
                EmptyState(title: Localization.emptyStateMessage, image: .emptyProductsTabImage)
                    .frame(maxHeight: .infinity)
            case .firstPageSync:
                List(viewModel.ghostRows) { rowViewModel in
                    ProductRow(viewModel: rowViewModel)
                        .redacted(reason: .placeholder)
                        .shimmering()
                }
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
                    Image(uiImage: .chevronLeftImage.imageFlippedForRightToLeftLayoutDirection())
                }
                .accessibilityLabel(Text(Localization.backButtonAccessibilityLabel))
            }
        }
        .onAppear {
            viewModel.onLoadTrigger.send()
        }
        .notice($viewModel.notice, autoDismiss: false)
    }
}

private extension AddProductVariationToOrder {
    enum Constants {
        static let dividerHeight: CGFloat = 1
        static let defaultPadding: CGFloat = 16
    }

    enum Localization {
        static let emptyStateMessage = NSLocalizedString("No product variations found",
                                                         comment: "Message displayed if there are no product variations for a product.")

        static let backButtonAccessibilityLabel = NSLocalizedString("Back", comment: "Accessibility label for Back button in the navigation bar")
    }
}

struct AddProductVariationToOrder_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AddProductVariationToOrderViewModel(siteID: 1, productID: 2, productName: "Monstera Plant", productAttributes: [])

        AddProductVariationToOrder(isPresented: .constant(true), viewModel: viewModel)
    }
}
