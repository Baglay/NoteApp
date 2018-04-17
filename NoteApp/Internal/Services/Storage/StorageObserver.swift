
import Foundation

protocol Observer: class {
    func didChangeTypeStorage(_ storageType: NoteStorageType)
}

protocol Observable: class {
    func register(observer: Observer)
    func remove(observer: Observer)
    func notifyObservers()
}


