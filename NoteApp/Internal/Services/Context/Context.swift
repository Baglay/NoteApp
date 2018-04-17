import Foundation

protocol Contextual {
    var context: Context? { get set }
}

// 'ServiceLocator' pattern
class Context {
    let preferences: Preferences
    let recordsManager: RecordsManager

    init(preferences: Preferences,
         recordsManager: RecordsManager) {
        self.preferences = preferences
        self.recordsManager = recordsManager
    }
}

extension Context {
    
    static func createStorageContext() -> Context? {
        let preferences = Preferences()
        let context = Context(
            preferences: preferences,
            recordsManager: RecordsManager(preferences:preferences)
        )
        return context
    }
}
