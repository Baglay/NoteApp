
import UIKit

protocol DetailRecordViewControllerDelegate: AnyObject {
    func detailRecordViewController(_: DetailRecordViewController, didChange record: Record, at index: Int)
}

class DetailRecordViewController: UIViewController {
    
    static let storyboardIndentifier: String = "DetailRecordViewController"
    var recordChange: (record: Record, index: Int)?
    weak var delegate: DetailRecordViewControllerDelegate?
    
    @IBOutlet private var recordNameLabel: UILabel!
    @IBOutlet private var recordNameTextField: UITextField!
    @IBOutlet private var recordTextTextView: UITextView!
    @IBOutlet private var recordChangeDateLabel: UILabel!
    @IBOutlet private  weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var recordImage: UIImageView!
    @IBOutlet private weak var saveButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocalizeController()
        setupMenuItem()
        recordNameTextField?.text = recordChange?.record.name
        recordTextTextView.text = recordChange?.record.text
        recordImage.image = recordChange?.record.image
        recordChangeDateLabel.text = "\(NSLocalizedString("record.detail.changeDateLabel.title", comment: "")) \(recordChange?.record.changeDate ?? "" )"
    }
}

//MARK:- Actions
private extension DetailRecordViewController {
    
    @objc func pasteImage() {
        showImagePickerViewController(with: .photoLibrary)
    }
    
    @IBAction func saveRecordsAction(_ sender: Any) {
        guard let name = recordNameTextField.text, let text = recordTextTextView.text,let dateChange = recordChangeDateLabel.text, let recordChanged =  recordChange?.record else {
            return
        }
        let record = Record(name: name, text: text, image: recordImage.image, createDate: recordChanged.createDate, changeDate: dateChange)
        if let change = recordChange {
            delegate?.detailRecordViewController(self, didChange: record, at: (change.index))
        }
    }
}

//MARK:- Touches
extension DetailRecordViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
}

// MARK:- UIImagePickerControllerDelegate
extension DetailRecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        recordImage.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- Image picker
private extension DetailRecordViewController {
    
    func showImagePickerViewController(with sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            imagePickerViewController.sourceType = sourceType
            present(imagePickerViewController, animated: true, completion: nil)
        }
    }
}

// MARK:- Menu Items
private extension DetailRecordViewController {
    
    func setupMenuItem() {
        let highlightMenuItem = UIMenuItem(title: NSLocalizedString("record.changeImage.title", comment: ""), action: #selector(DetailRecordViewController.pasteImage))
        UIMenuController.shared.menuItems = [highlightMenuItem]
    }
}

//MARK:- UITextViewDelegate
extension DetailRecordViewController: UITextViewDelegate {
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        recordChangeDateLabel.text = "\(CustomDateFormatter.stringWithFormat(type: .change))"
        return true
    }
}

//MARK:- UITextFieldDelegate
extension DetailRecordViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        recordChangeDateLabel.text = "\(CustomDateFormatter.stringWithFormat(type: .change))"
        return true
    }
}

//MARK:- Localizable string
private extension DetailRecordViewController {
    
    func configureLocalizeController() {
        saveButton.setTitle(NSLocalizedString("record.detail.saveButton.title", comment: ""), for: .normal)
    }
}
