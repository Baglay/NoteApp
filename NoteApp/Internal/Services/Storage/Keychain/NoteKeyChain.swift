
import Foundation
import SwiftKeychainWrapper

private enum NoteKeyChainKey {
    static let noteStorageKey = "NoteStorageKeyChain"
}

class NoteKeyChain: NoteStorageable {
    
    private(set) var records: [Record] = []
    private let serialQueue = DispatchQueue(label: "serialQueue.KEYCHAIN")
    
    init() {
        loadRecords { (value) in
            self.records = value
        }
    }
    
    func saveRecord(value: Record, completion: @escaping block) {
        serialQueue.sync {
            records.append(value)
            synchronize()
            DispatchQueue.main.async {
                completion(.success(self.records))
            }
        }
    }
    
    func getRecords(completion: @escaping block) {
        loadRecords { (value) in
            DispatchQueue.main.async {
                completion(.success(value))
            }
        }
    }
    
    func removeRecord(at index: Int, recordID: String, completion: @escaping block) {
        serialQueue.sync {
            records.remove(at: index)
            synchronize()
            DispatchQueue.main.async {
                completion(.success(self.records))
            }
        }
    }
    
    func changeRecord(_ record: Record, at index: Int, completion: @escaping block) {
        serialQueue.sync {
            records.remove(at: index)
            records.insert(record, at: index)
            synchronize()
            DispatchQueue.main.async {
                completion(.success(self.records))
            }
        }
    }
}

private extension NoteKeyChain {
    
    func loadRecords(completion: @escaping ([Record]) -> ()) {
        serialQueue.sync {
            if let data = KeychainWrapper.standard.data(forKey: NoteKeyChainKey.noteStorageKey)  {
                records = NSKeyedUnarchiver.unarchiveObject(with: data ) as! [Record]
                DispatchQueue.main.async {
                    completion(self.records)
                }
            }
            else {
                print("empty records")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func synchronize() {
        let keychain: KeychainWrapper = KeychainWrapper.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: records)
        keychain.set(encodedData, forKey: NoteKeyChainKey.noteStorageKey)
    }
}
