
import Foundation

private enum NoteUserDefaultsKey {
    static let noteStorageKey = "NoteStorageUserDefaults"
}

class NoteUserDefaults: NoteStorageable {
    
    private(set) var records: [Record] = []
    private let serialQueue = DispatchQueue(label: "serialQueue.USERDEFAULTS")
    
    init() {
        loadRecords { (value) in
            self.records = value
        }
    }
    
    func saveRecord(value: Record, completion: @escaping block) {
        serialQueue.sync {
            self.records.append(value)
            self.synchronize()
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

private extension NoteUserDefaults {
    
    func loadRecords(completion: @escaping ([Record]) -> ())  {
        serialQueue.sync {
            guard let data = UserDefaults.standard.data(forKey: NoteUserDefaultsKey.noteStorageKey)  else {
                print("empty records")
                completion([])
                return
            }
            self.records = NSKeyedUnarchiver.unarchiveObject(with: data ) as! [Record]
            DispatchQueue.main.async {
                completion(self.records)
            }
        }
    }
    
    func synchronize() {
        let userDefaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: records)
        userDefaults.set(encodedData, forKey: NoteUserDefaultsKey.noteStorageKey)
    }
}
