
import Foundation

enum NoteStorageType: Int {
    case userdefaults
    case keychain
}

private enum PreferencesKey {
    static let storageKey = "StorageKey"
}

class Preferences {
    
    private var observers: [Observer] = []
    
    init() {
        selectStorage(storageType: storageType)
    }
    
    var storageType: NoteStorageType {
        set {
             UserDefaults.standard.set(newValue.rawValue, forKey: PreferencesKey.storageKey)
        }
        get {
            let storageTypeID = UserDefaults.standard.integer(forKey: PreferencesKey.storageKey)
            let storageType = NoteStorageType(rawValue: storageTypeID)
            return storageType ?? .userdefaults
        }
    }
}

extension Preferences {
    
    func selectStorage(storageType: NoteStorageType)  {
        self.storageType = storageType
        notifyObservers()
    }
}

extension Preferences: Observable {
    
    func register(observer: Observer) {
        observers.append(observer)
    }
    
    func remove(observer: Observer) {
        observers = observers.filter {$0 !== observer }
    }
    
    func notifyObservers() {
        for observer in observers {
            observer.didChangeTypeStorage(storageType)
        }
    }
}
