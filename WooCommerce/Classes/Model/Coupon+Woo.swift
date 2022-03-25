import Foundation
import Yosemite

extension Coupon.DiscountType {
    /// Localized name to be displayed for the discount type.
    ///
    var localizedName: String {
        switch self {
        case .percent:
            return Localization.percentageDiscount
        case .fixedCart:
            return Localization.fixedCartDiscount
        case .fixedProduct:
            return Localization.fixedProductDiscount
        case .other:
            return Localization.otherDiscount
        }
    }

    private enum Localization {
        static let percentageDiscount = NSLocalizedString("Percentage Discount", comment: "Name of percentage discount type")
        static let fixedCartDiscount = NSLocalizedString("Fixed Cart Discount", comment: "Name of fixed cart discount type")
        static let fixedProductDiscount = NSLocalizedString("Fixed Product Discount", comment: "Name of fixed product discount type")
        static let otherDiscount = NSLocalizedString("Other", comment: "Generic name of non-default discount types")
    }
}

// MARK: - Coupon details
//
extension Coupon {

    /// Summary line for the coupon
    ///
    var summary: String {
        return ""
    }

    /// Formatted amount for the coupon
    ///
    func formattedAmount(currencySettings: CurrencySettings) -> String {
        var amountString: String = ""
        switch discountType {
        case .percent:
            let percentFormatter = NumberFormatter()
            percentFormatter.numberStyle = .percent
            if let amountDouble = Double(amount) {
                let amountNumber = NSNumber(value: amountDouble / 100)
                amountString = percentFormatter.string(from: amountNumber) ?? ""
            }
        case .fixedCart, .fixedProduct:
            let currencyFormatter = CurrencyFormatter(currencySettings: currencySettings)
            amountString = currencyFormatter.formatAmount(amount) ?? ""
        case .other:
            break // skip formatting for unsupported types
        }
        return amountString
    }

    /// Expiry status for Coupons.
    ///
    func expiryStatus(now: Date = Date()) -> ExpiryStatus {
        guard let expiryDate = dateExpires else {
            return .active
        }

        guard let gmtTimeZone = TimeZone(identifier: "GMT") else {
            return .expired
        }

        var calendar = Calendar.current
        calendar.timeZone = gmtTimeZone

        // Compare the dates by minute to get around edge cases of timezone differences.
        let result = calendar.compare(expiryDate, to: now, toGranularity: .minute)
        return result == .orderedDescending ? .active : .expired
    }
}

// MARK: - Subtypes
extension Coupon {
    /// Expiry status for coupons
    enum ExpiryStatus {
        case active
        case expired

        /// Localized name to be displayed for the expiry status.
        ///
        var localizedName: String {
            switch self {
            case .active:
                return Localization.active
            case .expired:
                return Localization.expired
            }
        }

        /// Background color for the expiry status label
        ///
        var statusBackgroundColor: UIColor {
            switch self {
            case .active:
                return .withColorStudio(.green, shade: .shade5)
            case .expired:
                return .gray(.shade5)
            }
        }

        private enum Localization {
            static let active = NSLocalizedString("Active", comment: "Status of coupons that are active")
            static let expired = NSLocalizedString("Expired", comment: "Status of coupons that are expired")
        }
    }

    private enum Localization {
        static let allProducts = NSLocalizedString(
            "all products",
            comment: "Text indicating that there's no limit to the number of products that a coupon can be applied for. Displayed on coupon list items and details screen"
        )
        static let singleProduct = NSLocalizedString(
            "%1$d Product",
            comment: "The number of products allowed for a coupon in singular form. Reads like: 1 Product"
        )
        static let multipleProducts = NSLocalizedString(
            "%1$d Products",
            comment: "The number of products allowed for a coupon in plural form. " +
            "Reads like: 10 Products"
        )
        static let singleCategory = NSLocalizedString(
            "%1$d Category",
            comment: "The number of category allowed for a coupon in singular form. Reads like: 1 Category"
        )
        static let multipleCategories = NSLocalizedString(
            "%1$d Categories",
            comment: "The number of category allowed for a coupon in plural form. " +
            "Reads like: 10 Categories"
        )
        static let summaryFormat = NSLocalizedString(
            "%1$@ off %2$@",
            comment: "Summary line for a coupon, with the discounted amount and number of products and categories that the coupon is limited to. " +
            "Reads like: '10% off all products' or '$15 off 2 Product 1 Category'"
        )
    }
}

// MARK: - Sample Data
#if DEBUG
extension Coupon {
    static let sampleCoupon = Coupon(couponID: 720,
                                     code: "AGK32FD",
                                     amount: "10.00",
                                     dateCreated: Date(timeIntervalSinceNow: -1000),
                                     dateModified: Date(timeIntervalSinceNow: -1000),
                                     discountType: .fixedCart,
                                     description: "Coupon description",
                                     dateExpires: Date(timeIntervalSinceNow: 1000),
                                     usageCount: 10,
                                     individualUse: true,
                                     productIds: [],
                                     excludedProductIds: [12213],
                                     usageLimit: 1200,
                                     usageLimitPerUser: 3,
                                     limitUsageToXItems: 10,
                                     freeShipping: true,
                                     productCategories: [123, 435, 232],
                                     excludedProductCategories: [908],
                                     excludeSaleItems: false,
                                     minimumAmount: "5.00",
                                     maximumAmount: "500.00",
                                     emailRestrictions: ["*@a8c.com", "someone.else@example.com"],
                                     usedBy: ["someone.else@example.com", "person@a8c.com"])
}
#endif
