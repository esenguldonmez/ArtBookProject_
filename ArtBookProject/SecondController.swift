//
//  SecondController.swift
//  ArtBookProject
//
//  Created by Esengul Donmez on 17.06.2023.
//

import UIKit
import CoreData

class SecondController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var artImage: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var artistText: UITextField!
    
    @IBOutlet weak var yearText: UITextField!

    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            saveButton.isHidden = true
            //Boş değilse CoreData'dan verileri getir.
            let  appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            
            //id'leri eşleştirip doğru veriyi çekme işlemi
            let idString = chosenPaintingID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do{
              let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            artImage.image = image
                        }
                    }
                }
            }catch{
                
            }
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            artistText.text = ""
            nameText.text = ""
            yearText.text = ""
        }
        
        
        
        //Recognizer
        
        //Ekrana tıklandığında klavye kapatılır.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        //Fotoğrafa tıklandığında işlem yapabilmek için tıklanabilirliği açıldı.
        artImage.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        artImage.addGestureRecognizer(imageRecognizer)
    }
      
    //Fotoğrafa tıklandığında kütüphane açılır.
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    //Fotoğraf kapatıldığında yapılacak işlemler yazılır.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        artImage.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        
        newPainting.setValue(UUID(), forKey: "id")
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        let data = artImage.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        //Sayfa kapandığında işlemleri yenilemesini söylemek için atandı.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        //işlem bittiğinde bir önceki sayfaya gider
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
