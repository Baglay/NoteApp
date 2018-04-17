
import UIKit


protocol SettingViewControllerDelegate: AnyObject {
    func settingsViewControllerDidChangeStorage(_: SettingsViewController)
}

class SettingsViewController: UITableViewController {
    static let storyboardIndentifier: String = "SettingsViewController"
    var preferences: Preferences?
    weak var delegate: SettingViewControllerDelegate?
    
    @IBOutlet private weak var noteComplexityButton: UISegmentedControl!
    @IBOutlet private weak var noteStorageButton: UISegmentedControl!
    @IBOutlet private weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocalizeController()
        if let settings = preferences {
            noteStorageButton.selectedSegmentIndex = settings.storageType.rawValue
        }
    }
}

//MARK:- SettingsViewController - Actions
private extension SettingsViewController {
    
    @IBAction func noteStoreAction(_ sender: UISegmentedControl) {
        guard let storageType = NoteStorageType(rawValue: noteStorageButton.selectedSegmentIndex) else {
            return
        }
        preferences?.selectStorage(storageType: storageType)
    }
    
    @IBAction func saveSettingsAction(_ sender: UIButton) {
        delegate?.settingsViewControllerDidChangeStorage(self)
    }
}

//MARK:- Localizable Controller
private extension SettingsViewController {
    
    func configureLocalizeController() {
        saveButton.setTitle(NSLocalizedString("record.settings.saveButton.title", comment: ""), for: .normal)
        noteStorageButton.setTitle(NSLocalizedString("record.settings.storageSegmentedControl.userdefaults.title", comment: ""), forSegmentAt: 0)
        noteStorageButton.setTitle(NSLocalizedString("record.settings.storageSegmentedControl.keychain.title", comment: ""), forSegmentAt: 1)
    }
}
