import Yosemite
import protocol Storage.StorageManagerType
import Combine

/// View model for `AddProductVariationToOrder`.
///
final class AddProductVariationToOrderViewModel: ObservableObject {
    private let siteID: Int64

    /// Storage to fetch product variation list
    ///
    private let storageManager: StorageManagerType

    /// Stores to sync product variation list
    ///
    private let stores: StoresManager

    /// Store for publishers subscriptions
    ///
    private var subscriptions = Set<AnyCancellable>()

    /// Trigger to perform any one time setups.
    ///
    let onLoadTrigger: PassthroughSubject<Void, Never> = PassthroughSubject()

    /// The ID of the parent variable product
    ///
    private let productID: Int64

    /// The name of the parent variable product
    ///
    let productName: String

    /// All attributes for variations of the parent variable product
    ///
    private let productAttributes: [ProductAttribute]

    /// All purchasable product variations for the product.
    ///
    private var productVariations: [ProductVariation] {
        productVariationsResultsController.fetchedObjects
            .filter { $0.purchasable }
            .sorted {
                if $0.menuOrder == $1.menuOrder {
                    return ProductVariationFormatter().generateName(for: $0, from: productAttributes) <
                        ProductVariationFormatter().generateName(for: $1, from: productAttributes)
                }
                return $0.menuOrder < $1.menuOrder
            }
    }

    /// View models for each product variation row
    ///
    var productVariationRows: [ProductRowViewModel] {
        return productVariations.map {
            .init(productVariation: $0,
                  name: ProductVariationFormatter().generateName(for: $0, from: productAttributes),
                  canChangeQuantity: false,
                  displayMode: .stock)
        }
    }

    /// Closure to be invoked when a product variation is selected
    ///
    let onVariationSelected: ((ProductVariation) -> Void)?

    // MARK: Sync & Storage properties

    /// Current sync status; used to determine what list view to display.
    ///
    @Published private(set) var syncStatus: SyncStatus?

    /// SyncCoordinator: Keeps tracks of which pages have been refreshed, and encapsulates the "What should we sync now" logic.
    ///
    private let syncingCoordinator = SyncingCoordinator()

    /// Tracks if the infinite scroll indicator should be displayed
    ///
    @Published private(set) var shouldShowScrollIndicator = false

    /// View models of the ghost rows used during the loading process.
    ///
    var ghostRows: [ProductRowViewModel] {
        return Array(0..<6).map { index in
            ghostProductRow(id: index)
        }
    }

    /// Product Variations Results Controller.
    ///
    private lazy var productVariationsResultsController: ResultsController<StorageProductVariation> = {
        let predicate = NSPredicate(format: "siteID == %lld AND productID == %lld", siteID, productID)
        let descriptor = NSSortDescriptor(keyPath: \StorageProductVariation.menuOrder, ascending: true)
        let resultsController = ResultsController<StorageProductVariation>(storageManager: storageManager, matching: predicate, sortedBy: [descriptor])
        return resultsController
    }()

    init(siteID: Int64,
         productID: Int64,
         productName: String,
         productAttributes: [ProductAttribute],
         storageManager: StorageManagerType = ServiceLocator.storageManager,
         stores: StoresManager = ServiceLocator.stores,
         onVariationSelected: ((ProductVariation) -> Void)? = nil) {
        self.siteID = siteID
        self.productID = productID
        self.productName = productName
        self.productAttributes = productAttributes
        self.storageManager = storageManager
        self.stores = stores
        self.onVariationSelected = onVariationSelected

        configureSyncingCoordinator()
        configureProductVariationsResultsController()
        configureFirstPageLoad()
    }

    convenience init(siteID: Int64,
                     product: Product,
                     storageManager: StorageManagerType = ServiceLocator.storageManager,
                     stores: StoresManager = ServiceLocator.stores,
                     onVariationSelected: ((ProductVariation) -> Void)? = nil) {
        self.init(siteID: siteID,
                  productID: product.productID,
                  productName: product.name,
                  productAttributes: product.attributesForVariations,
                  storageManager: storageManager,
                  stores: stores,
                  onVariationSelected: onVariationSelected)
    }

    /// Select a product variation to add to the order
    ///
    func selectVariation(_ variationID: Int64) {
        guard let selectedVariation = productVariations.first(where: { $0.productVariationID == variationID }) else {
            return
        }
        onVariationSelected?(selectedVariation)
    }
}

// MARK: - SyncingCoordinatorDelegate & Sync Methods
extension AddProductVariationToOrderViewModel: SyncingCoordinatorDelegate {
    /// Sync product variations from remote.
    ///
    func sync(pageNumber: Int, pageSize: Int, reason: String? = nil, onCompletion: ((Bool) -> Void)?) {
        transitionToSyncingState()
        let action = ProductVariationAction.synchronizeProductVariations(siteID: siteID,
                                                                         productID: productID,
                                                                         pageNumber: pageNumber,
                                                                         pageSize: pageSize) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                DDLogError("⛔️ Error synchronizing product variations during order creation: \(error)")
            } else {
                self.updateProductVariationsResultsController()
            }

            self.transitionToResultsUpdatedState()
            onCompletion?(error == nil)
        }
        stores.dispatch(action)
    }

    /// Sync first page of product variations from remote if needed.
    ///
    func syncFirstPage() {
        syncingCoordinator.synchronizeFirstPage()
    }

    /// Sync next page of product variations from remote.
    ///
    func syncNextPage() {
        let lastIndex = productVariationsResultsController.numberOfObjects - 1
        syncingCoordinator.ensureNextPageIsSynchronized(lastVisibleIndex: lastIndex)
    }
}

// MARK: - Finite State Machine Management
private extension AddProductVariationToOrderViewModel {
    /// Update state for sync from remote.
    ///
    func transitionToSyncingState() {
        shouldShowScrollIndicator = true
        if productVariations.isEmpty {
            syncStatus = .firstPageSync
        }
    }

    /// Update state after sync is complete.
    ///
    func transitionToResultsUpdatedState() {
        shouldShowScrollIndicator = false
        syncStatus = productVariations.isNotEmpty ? .results: .empty
    }
}

// MARK: - Configuration
private extension AddProductVariationToOrderViewModel {
    /// Performs initial fetch from storage and updates sync status accordingly.
    ///
    func configureProductVariationsResultsController() {
        updateProductVariationsResultsController()
        transitionToResultsUpdatedState()
    }

    /// Fetches product variations from storage.
    ///
    func updateProductVariationsResultsController() {
        do {
            try productVariationsResultsController.performFetch()
        } catch {
            DDLogError("⛔️ Error fetching product variations for new order: \(error)")
        }
    }

    /// Setup: Syncing Coordinator
    ///
    func configureSyncingCoordinator() {
        syncingCoordinator.delegate = self
    }

    /// Performs initial sync on first page load
    ///
    func configureFirstPageLoad() {
        // Listen only to the first emitted event.
        onLoadTrigger.first()
            .sink { [weak self] in
                guard let self = self else { return }
                self.syncFirstPage()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Utils
extension AddProductVariationToOrderViewModel {
    /// Represents possible statuses for syncing product variations
    ///
    enum SyncStatus {
        case firstPageSync
        case results
        case empty
    }

    /// Used for ghost list view while syncing
    ///
    private func ghostProductRow(id: Int64) -> ProductRowViewModel {
        ProductRowViewModel(productOrVariationID: id,
                            name: "Ghost Variation",
                            sku: nil,
                            price: "20",
                            stockStatusKey: ProductStockStatus.inStock.rawValue,
                            stockQuantity: 1,
                            manageStock: false,
                            canChangeQuantity: false,
                            imageURL: nil)
    }
}
