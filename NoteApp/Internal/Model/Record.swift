
import Foundation
import UIKit



private enum RecordPropertyKey {
    static let name = "name"
    static let text = "text"
    static let image = "image"
    static let createDate = "createDate"
    static let changeDate = "changeDate"
}




class Record: NSObject, NSCoding {
    
    let name: String
    let text: String
    var image: UIImage?
    let createDate: String
    let changeDate: String
    
    init(name: String, text: String, image: UIImage?, createDate: String, changeDate: String) {
        self.name = name
        self.text = text
        self.image = image
        self.createDate = createDate
        self.changeDate = changeDate
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let name =  aDecoder.decodeObject(forKey: RecordPropertyKey.name) as? String,
            let text = aDecoder.decodeObject(forKey: RecordPropertyKey.text) as? String,
            let image = aDecoder.decodeObject(forKey: RecordPropertyKey.image) as? UIImage,
            let createDate = aDecoder.decodeObject(forKey: RecordPropertyKey.createDate) as? String,
            let changeDate = aDecoder.decodeObject(forKey: RecordPropertyKey.changeDate) as? String else {
               return nil
        }
        self.init(name: name, text: text, image: image, createDate: createDate, changeDate: changeDate)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey:  RecordPropertyKey.name)
        aCoder.encode(text, forKey: RecordPropertyKey.text)
      
        if let thumbImage = image {
            aCoder.encode(thumbImage, forKey: RecordPropertyKey.image)
        }
        aCoder.encode(createDate, forKey: RecordPropertyKey.createDate)
        aCoder.encode(changeDate, forKey: RecordPropertyKey.changeDate)
    }
}
