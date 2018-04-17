import UIKit

enum typeReloadUI {
    case remove
    case register,change,get
}

class RecordsViewController: UIViewController, Contextual {
    private static var recordsCellReuseID = "ReusableCellID"
    var context: Context?
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var settingsButton: UIBarButtonItem!
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.title = NSLocalizedString("settings.button.title", comment: "")
        context = Context.createStorageContext()
        activityIndicator.startAnimating()
        context?.recordsManager.getRecords(completion: { [weak self] recordsResult in
            self?.reloadUI(withType: .get, value: recordsResult)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        context?.recordsManager.getRecords(completion: { [weak self] recordsResult in
            self?.reloadUI(withType: .get, value: recordsResult)
        })
    }
}

// MARK: - UITableViewDataSource
extension RecordsViewController: UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return context?.recordsManager.records.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecordTableViewCell = tableView.dequeueReusableCell(withIdentifier: RecordsViewController.recordsCellReuseID, for: indexPath) as! RecordTableViewCell
        if let record = context?.recordsManager.records[indexPath.row] {
            cell.nameLabel?.text = record.name
            cell.fullTextLabel?.text = record.text
            cell.createDateLabel?.text = record.createDate
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString( "record.main.deleteButton.title", comment: "")) {
            _, indexPath in
            guard let recordID = self.context?.recordsManager.records[indexPath.row].name else { return }
            self.activityIndicator.startAnimating()
            self.context?.recordsManager.removeRecord(at: indexPath.row,recordID: recordID , completion: { [weak self] recordsResult in
                self?.reloadUI(withType: .remove, value: recordsResult, indexPath: indexPath)
            })
        }
        return [deleteAction]
    }
}

// MARK: - UITableViewDelegate
extension RecordsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = DetailRecordViewController.storyboardIndentifier
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle.main)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! DetailRecordViewController
        detailViewController.delegate = self
        let row = indexPath.row
        guard let context = context else {
            return
        }
        detailViewController.recordChange = (record: context.recordsManager.records[row], row)
        let navigationController = UINavigationController(rootViewController: detailViewController)
        present(navigationController, animated: true, completion: nil)
    }
}

/// MARK: - Actions
private extension RecordsViewController {
    
    @IBAction func didTouchAddBarButtonItem() {
        let identifier = NewRecordViewController.storyboardIndentifier
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle.main)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! NewRecordViewController
        rootViewController.delegate = self
        rootViewController.preferences = context?.preferences
        let navigationController = UINavigationController(rootViewController: rootViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func didTouchSettingsBarButtonItem() {
        let identifier = SettingsViewController.storyboardIndentifier
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle.main)
        let settingsViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! SettingsViewController
        settingsViewController.delegate = self
        settingsViewController.preferences = context?.preferences
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func didTouchRefreshBarButtonItem() {
        self.activityIndicator.startAnimating()
        context?.recordsManager.getRecords(completion: { [weak self] recordsResult in
            self?.reloadUI(withType: .get, value: recordsResult)
        })
    }
}

//MARK: - delegate
extension RecordsViewController: SettingViewControllerDelegate {
   
    func settingsViewControllerDidChangeStorage(_: SettingsViewController) {
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
}

extension RecordsViewController: NewRecordViewControllerDelegate {
  
    func newRecordViewController(sender: NewRecordViewController, didTapCancel cancel: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
    func newRecordViewController(sender: NewRecordViewController, didTapSaveWithRecord record: Record) {
        dismiss(animated: true, completion: nil)
        activityIndicator.startAnimating()
        context?.recordsManager.saveRecord(value: record, completion: { [weak self] recordsResult in
            self?.reloadUI(withType: .register, value: recordsResult)
        })
    }
}

extension RecordsViewController: DetailRecordViewControllerDelegate {
    
    func detailRecordViewController(_: DetailRecordViewController, didChange record: Record, at index: Int) {
        dismiss(animated: true, completion: nil)
        self.activityIndicator.startAnimating()
        context?.recordsManager.changeRecord(record, at: index, completion: { [weak self] recordsResult in
            self?.reloadUI(withType: .change, value: recordsResult)
        })
    }
}

private extension RecordsViewController {
   
    func showError(error: Error){
        let errorAllert = UIAlertController(title: NSLocalizedString("record.main.alertController.title", comment: ""), message: NSLocalizedString("record.main.alertController.message", comment: "") + " \(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("record.main.alertAction.ok.title", comment: ""), style: .cancel, handler: nil)
        errorAllert.addAction(okAction)
        present(errorAllert, animated: true, completion: nil)
    }
    
    func reloadUI(withType: typeReloadUI, value: RecordsResult<[Record]>, indexPath: IndexPath? = nil) {
        activityIndicator.stopAnimating()
        switch value {
        case .success(_):
            guard withType != .remove else {
                if let index = indexPath {
                    tableView.deleteRows(at: [index], with: .automatic)
                }
                return
            }
            tableView.reloadData()
        case .failure(let error):
            showError(error: error)
        }
    }
}
