//
//  ViewController.swift
//  Project10
//
//  Created by Edwin Przeźwiecki Jr. on 12/07/2022.
//

/// *The solution to the third challenge and Project 12b can be found in separate repositories.*

/// Project 28, challenge 3:
import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    
    /// Project 28, challenge 3:
    var hiddenPeople = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Project 12a:
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                people = decodedPeople
            }
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        /// Project 28, challenge 3:
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(savePeople), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(authenticate), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /// Project 28, challenge 3:
    @objc func savePeople() {
        hiddenPeople += people
        people = [Person]()
        
        collectionView.reloadData()
    }
    
    /// Project 28, challenge 3:
    func loadPeople() {
        people += hiddenPeople
        hiddenPeople = [Person]()
        
        collectionView.reloadData()
    }
    
    /// Project 28, challenge 3:
    @objc func authenticate() {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please identify yourself."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self?.loadPeople()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified. Please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    ///Challenge 1:
    
    /* override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     let person = people[indexPath.item]
     
     let alertController = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
     alertController.addTextField()
     
     alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
     
     alertController.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] _ in
         guard let newName = alertController?.textFields?[0].text else { return }
         person.name = newName
         
         self?.collectionView.reloadData()
     })
     present(alertController, animated: true)
 } */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let person = people[indexPath.item]
        
        let setANameAC = UIAlertController(title: "Set a name", message: "Please enter a name.", preferredStyle: .alert)
        
        setANameAC.addTextField()
        setANameAC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        setANameAC.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak setANameAC] _ in
            
            guard let newName = setANameAC?.textFields?[0].text else { return }
            
            person.name = newName
            
            self?.collectionView.reloadData()
            /// Project 12a:
            self?.save()
        })
        
        let deleteAPersonAC = UIAlertController(title: "Delete a person", message: "Are you sure you would like to delete this person?", preferredStyle: .alert)
        
        deleteAPersonAC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        deleteAPersonAC.addAction(UIAlertAction(title: "Delete", style: .default) { UIAlertAction in
            
            self.people.remove(at: indexPath.item)
            
            self.collectionView.reloadData()
            /// Project 12a:
            self.save()
        })
        
        let alertController = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Set a name", style: .default) { UIAlertAction in
            DispatchQueue.main.async {
                self.present(setANameAC, animated: true)
            }
        })
        alertController.addAction(UIAlertAction(title: "Delete a person", style: .default) { UIAlertAction in
            DispatchQueue.main.async {
                self.present(deleteAPersonAC, animated: true)
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @objc func addNewPerson() {
        
        let picker = UIImagePickerController()
        
        picker.allowsEditing = true
        
        /// Challenge 2:
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
                picker.sourceType = .photoLibrary
            }
        
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        
        people.append(person)
        
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /// Project 12a:
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            
            let defaults = UserDefaults.standard
            
            defaults.set(savedData, forKey: "people")
        }
    }
}
