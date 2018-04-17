import Foundation

final class RecordsManager: NoteStorageable {
    
    var records: [Record] {
        return storage.records
    }
    
    private var preferences: Preferences
    private var storage: NoteStorageable!
    
    init(preferences: Preferences) {
        self.preferences = preferences
        didChangeTypeStorage(preferences.storageType)
        preferences.register(observer: self)
    }
    
    deinit {
        preferences.remove(observer: self)
    }
    
    func saveRecord(value: Record, completion: @escaping block) {
        storage.saveRecord(value: value, completion: { (recordsResult) in
            switch recordsResult {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getRecords(completion: @escaping block)  {
        storage.getRecords { (recordsResult) in
            switch recordsResult {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeRecord(at index: Int, recordID: String, completion: @escaping block) {
        storage.removeRecord(at: index, recordID: recordID, completion: { (recordsResult) in
            switch recordsResult {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func changeRecord(_ record: Record, at index: Int, completion: @escaping block) {
        storage.changeRecord(record, at: index, completion: { (recordsResult) in
            switch recordsResult {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}

extension RecordsManager: Observer {
    func didChangeTypeStorage(_ storageType: NoteStorageType) {
        switch storageType {
        case .userdefaults:
            storage = NoteUserDefaults()
            print("USERDEFAULTS")
        case .keychain:
            storage = NoteKeyChain()
            print("KEYCHAIN")
        }
    }
}
