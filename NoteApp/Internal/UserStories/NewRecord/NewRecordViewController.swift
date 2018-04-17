import UIKit
import Foundation

protocol NewRecordViewControllerDelegate: AnyObject {
    func newRecordViewController(sender: NewRecordViewController, didTapSaveWithRecord record: Record)
    func newRecordViewController(sender: NewRecordViewController, didTapCancel cancel: Bool)
}

class NewRecordViewController: UIViewController {
    static let storyboardIndentifier: String = "NewRecordViewController"
    var preferences: Preferences?
    var keyboardHeight: CGFloat = 0.0
    var imageRecord: UIImage!
    weak var delegate: NewRecordViewControllerDelegate?
    
    @IBOutlet private var recordNameLabel: UILabel!
    @IBOutlet private var recordNameTextField: UITextField!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var recordTextTextView: UITextView!
    @IBOutlet private var recordCreateDateLabel: UILabel!
    @IBOutlet private var recordImage: UIImageView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocalizeController()
        setupNavbar()
        setupMenuItem()
        self.addKeyboardNotification()
    }
    
    deinit {
        self.removeKeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK:- Touches
extension NewRecordViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
}

// MARK:- Auxiliaries
private extension NewRecordViewController {
    
    func saveRecord() -> Bool {
        guard let name = recordNameTextField.text,
            let text = recordTextTextView.text,
            !name.isEmpty, !text.isEmpty,
            let image = recordImage.image  else {
                showError()
                return false
                
        }
        
        let createDate = CustomDateFormatter.stringWithFormat(type: .create)
        let changeDate = CustomDateFormatter.stringWithFormat(type: .change)
        let record = Record(name: name, text: text, image: image, createDate: createDate, changeDate: changeDate)
        delegate?.newRecordViewController(sender: self, didTapSaveWithRecord: record)
        return true
    }
}

// MARK:- UITextFieldDelegate
extension NewRecordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return saveRecord()
    }
}

// MARK:- Actions
private extension NewRecordViewController {
    
    func setupNavbar() {
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                                            action: #selector(NewRecordViewController.didTouchCancelBarButtonItem))
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                             action: #selector(NewRecordViewController.didTouchSaveBarButtonItem))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func didTouchCancelBarButtonItem() {
        delegate?.newRecordViewController(sender: self, didTapCancel: true)
    }
    
    @objc func didTouchSaveBarButtonItem() {
        _ = saveRecord()
    }
    
    @objc func pasteImage() {
        showImagePickerViewController(with: .photoLibrary)
    }
    
    @IBAction func pickerTap(_ sender: UIButton) {
        showImagePickerViewController(with: .photoLibrary)
    }
}

// MARK:- UIImagePickerControllerDelegate
extension NewRecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
private extension NewRecordViewController {
    
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
private extension NewRecordViewController {
    
    func setupMenuItem() {
        let highlightMenuItem = UIMenuItem(title: NSLocalizedString("record.pasteImage.title", comment: ""), action: #selector(NewRecordViewController.pasteImage))
        UIMenuController.shared.menuItems = [highlightMenuItem]
    }
}


// MARK:- Notifications
private extension NewRecordViewController {
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, self.keyboardHeight <= 0.0 {
            self.keyboardHeight = keboardFrame.height + 45
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.textViewBottomConstraint.constant = self.keyboardHeight
        }, completion: { (success) in
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.textViewBottomConstraint.constant = 0.0
        }, completion: { (success) in
        })
    }
}

// MARK:- Localizable text
private extension NewRecordViewController {
    
    func configureLocalizeController() {
        recordCreateDateLabel?.text = CustomDateFormatter.stringWithFormat(type: .create)
        textLabel.text = NSLocalizedString("record.new.texNoteLabel.title", comment: "")
        recordNameLabel.text = NSLocalizedString("record.new.nameNoteLabel.title", comment: "")
    }
}

private extension NewRecordViewController {
    func showError(){
        let errorAllert = UIAlertController(title: NSLocalizedString("record.newRecord.error.title", comment: ""), message: NSLocalizedString("record.newRecord.error.message", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("record.main.alertAction.ok.title", comment: ""), style: .cancel, handler: nil)
        errorAllert.addAction(okAction)
        present(errorAllert, animated: true, completion: nil)
    }
}

