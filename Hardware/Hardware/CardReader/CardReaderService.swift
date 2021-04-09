import Combine

/// Abstracts the integration with a Card Reader
public protocol CardReaderService {

    // MARK: - Queries
    /// The publisher that emits the list of discovered readers whenever the service discovers a new reader.
    var discoveredReaders: AnyPublisher<[CardReader], Never> { get }

    /// The Publisher that emits the connected readers
    var connectedReaders: AnyPublisher<[CardReader], Never> { get }

    /// The Publisher that emits the service status
    var serviceStatus: AnyPublisher<CardReaderServiceStatus, Never> { get }

    /// The Publisher that emits the service discovery status
    var discoveryStatus: AnyPublisher<CardReaderServiceDiscoveryStatus, Never> { get }

    /// The Publisher that emits the payment status
    var paymentStatus: AnyPublisher<PaymentStatus, Never> { get }

    /// The Publisher that emits reader events
    var readerEvents: AnyPublisher<CardReaderEvent, Never> { get }

    // MARK: - Commands

    /// Starts the service.
    /// That could imply, for example, that the reader discovery process starts
    func start(_ configProvider: CardReaderConfigProvider)

    /// Cancels the discovery process.
    func cancelDiscovery()

    /// Connects to a card reader
    /// - Parameter reader: The card reader we want to connect to.
    func connect(_ reader: CardReader) -> Future <Void, Error>

    /// Disconnects a card reader
    /// - Parameter reader: The card reader we want to connect to.
    func disconnect(_ reader: CardReader) -> Future <Void, Error>

    /// Clears and resets internal state.
    /// We need to call this method when switching accounts or stores
    func clear()

    /// Captures a payment after collecting a payment method succeeds.
    func capturePayment(_ parameters: PaymentIntentParameters) -> AnyPublisher<PaymentIntent, Error>

    /// Cancels a a PaymentIntent
    /// If the cancel request succeeds, the promise will be called with the updated PaymentIntent object with status Canceled
    func cancelPaymentIntent(_ intent: PaymentIntent) -> Future<PaymentIntent, Error>

    /// Checks for firmware updates.
    func checkForUpdate() -> Future<CardReaderSoftwareUpdate, Error>
}
