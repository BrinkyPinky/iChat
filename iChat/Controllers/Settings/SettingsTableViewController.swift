//
//  SettingsTableViewController.swift
//  iChat
//
//  Created by Егор Шилов on 08.09.2022.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userFullname: UILabel!
    @IBOutlet var userUsername: UILabel!
    
    var viewModel: SettingsViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SettingsViewModel(view: self)
        userImage.layer.cornerRadius = userImage.frame.size.width/2
        userFullname.text = UserLoginDataManager.shared.fullname
        userUsername.text = "@\(UserLoginDataManager.shared.username ?? "Unknown")"
    }
    
    func showAlert(with message: String) {
        let alert = UIAlertController(title: "Check your e-mail", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
        present(alert, animated: true, completion: nil)
    }
}

extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.rows.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.rows[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier, for: indexPath) as! SettingsTableViewCell
        
        cell.cellViewModel = cellViewModel
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = viewModel.rows[indexPath.section][indexPath.row] as! SettingCellViewModel
        tableView.deselectRow(at: indexPath, animated: true)
        cellViewModel.handler()
    }
}

extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        userImage.image = image
        viewModel.pickedImage(with: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
