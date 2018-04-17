
import Foundation

enum typeForDateFormatter {
    case change
    case create
}

class CustomDateFormatter {
    
    static func stringWithFormat(type: typeForDateFormatter) -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.locale = Locale(identifier: Locale.current.description)
        switch type {
        case .create:
            dateFormatter.dateFormat = "MM.dd.yyyy"
            return dateFormatter.string(from: date)
        case .change:
            dateFormatter.dateFormat = "MMM d, h:mm"
            return dateFormatter.string(from: date)
        }
    }
}
