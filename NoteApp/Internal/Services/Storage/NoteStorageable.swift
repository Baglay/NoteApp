
import Foundation

enum RecordsResult<A: Codable> {
    case success (A)
    case failure(Error)
}

typealias block = (RecordsResult<[Record]>) -> ()

protocol NoteStorageable: AnyObject {
    var records: [Record] { get }
    func saveRecord(value: Record, completion: @escaping block)
    func getRecords(completion: @escaping block)
    func removeRecord(at index: Int, recordID: String, completion: @escaping block)
    func changeRecord(_ record: Record, at index: Int, completion: @escaping block)
}

