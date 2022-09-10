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
    
    
    let imagePickerController = UIImagePickerController()
    
    var viewModel: SettingsViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
        present(alert, animated: true, completion: nil)
    }
    
    func setupUI() {
        viewModel = SettingsViewModel(view: self)
        viewModel.viewLoad()
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        userImage.layer.cornerRadius = userImage.frame.size.width/2
    }
    
    // MARK: Displaying UserData from ViewModel
    
    func displayUsername(with username: String) {
        userUsername.text = username
    }
    
    func displayFullname(with fullname: String) {
        userFullname.text = fullname
    }
    
    func displayUserImage(with data: Data) {
        userImage.image = UIImage(data: data)
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
        
        guard let data = image?.jpegData(compressionQuality: 0.4) else {
            showAlert(title: "Error", message: "Something went wrong with uploading the image to the server")
            return
        }
        
        viewModel.pickedImage(with: data)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
