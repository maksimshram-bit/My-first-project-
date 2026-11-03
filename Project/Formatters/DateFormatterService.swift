import Foundation

protocol DateFormatterServiceProtocol {
    func apiString(from date: Date) -> String
    func date(from apiString: String) -> Date?
}

final class DateFormatterService: DateFormatterServiceProtocol {

    private let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    func apiString(from date: Date) -> String {
        shortFormatter.string(from: date)
    }

    func date(from apiString: String) -> Date? {
        isoFormatter.date(from: apiString)
    }
}
