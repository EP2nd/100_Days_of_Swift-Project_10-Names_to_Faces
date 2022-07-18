import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
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
        })
        
        let deleteAPersonAC = UIAlertController(title: "Delete a person", message: "Are you sure you would like to delete this person?", preferredStyle: .alert)
        deleteAPersonAC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        deleteAPersonAC.addAction(UIAlertAction(title: "Delete", style: .default) { UIAlertAction in
            self.people.remove(at: indexPath.item)
            self.collectionView.reloadData()
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
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func deletePerson() {
        
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
}

