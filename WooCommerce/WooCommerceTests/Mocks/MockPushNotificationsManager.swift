import Combine
import Foundation
import UIKit
@testable import WooCommerce
import Yosemite

final class MockPushNotificationsManager: PushNotesManager {

    var foregroundNotifications: AnyPublisher<PushNotification, Never> {
        foregroundNotificationsSubject.eraseToAnyPublisher()
    }

    private let foregroundNotificationsSubject = PassthroughSubject<PushNotification, Never>()

    var foregroundNotificationsToView: AnyPublisher<PushNotification, Never> {
        foregroundNotificationsToViewSubject.eraseToAnyPublisher()
    }

    private let foregroundNotificationsToViewSubject = PassthroughSubject<PushNotification, Never>()

    var inactiveNotifications: AnyPublisher<PushNotification, Never> {
        inactiveNotificationsSubject.eraseToAnyPublisher()
    }

    private let inactiveNotificationsSubject = PassthroughSubject<PushNotification, Never>()

    func resetBadgeCount(type: Note.Kind) {

    }

    func resetBadgeCountForAllStores() async {

    }

    func reloadBadgeCount() {

    }

    func registerForRemoteNotifications() {

    }

    func unregisterForRemoteNotifications() {

    }

    func ensureAuthorizationIsRequested(onCompletion: ((Bool) -> ())?) {

    }

    func registrationDidFail(with error: Error) {

    }

    func registerDeviceToken(with tokenData: Data, defaultStoreID: Int64) {

    }

    func handleNotification(_ userInfo: [AnyHashable: Any],
                            onBadgeUpdateCompletion: @escaping () -> Void,
                            completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }
}

extension MockPushNotificationsManager {
    /// Send a `PushNotification` that will be emitted by the `foregroundNotifications`
    /// observable.
    ///
    func sendForegroundNotification(_ notification: PushNotification) {
        foregroundNotificationsSubject.send(notification)
    }

    /// Send a `PushNotification` that will be emitted by the `foregroundNotificationsToView`
    /// observable.
    ///
    func sendForegroundNotificationToView(_ notification: PushNotification) {
        foregroundNotificationsToViewSubject.send(notification)
    }

    /// Send a `PushNotification` that will be emitted by the `inactiveNotifications`
    /// observable.
    ///
    func sendInactiveNotification(_ notification: PushNotification) {
        inactiveNotificationsSubject.send(notification)
    }
}
