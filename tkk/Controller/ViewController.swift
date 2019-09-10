//
//  ViewController.swift
//  tkk
//
//  Created by Hasan Saral on 9.09.2019.
//  Copyright © 2019 Hasan. All rights reserved.
//
import CoreML
import Vision
import UIKit


class ViewController: UIViewController, UITabBarControllerDelegate {

    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    let picker = UIImagePickerController()
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredPhotos = [PhotoItem]()
    var photos = [PhotoItem]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self

        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .popover
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Fotoğraf Ara"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        
    }
  
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searcText: String, scope: String = "All") {
        
        var filtered = [PhotoItem]()
        
        for photo in self.photos {
            if photo.predictedLabel.prefix(searcText.count) == searcText {
                filtered.append(photo)
            }
        }
        self.filteredPhotos = filtered
        photosCollectionView.reloadData()
    }
    
  
    
    func predictImage(image: UIImage) {
        
        guard let model = try? VNCoreMLModel(for: FruitDetector_1_1().model) else {return}
        
        let request = VNCoreMLRequest(model: model) { (finishedReg, err) in
            
            guard let results = finishedReg.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            self.photos.append(PhotoItem(photo: image, predictedLabel: firstObservation.identifier))
        }
        
        try? VNImageRequestHandler(cgImage: image.cgImage!, options: [:]).perform([request])
    }
    
    @IBAction func addPhotoBarButtonItemTapped(_ sender: Any) {
        
        present(picker, animated: true, completion: nil)
    }
    
    
    func getImage(image: UIImage) {
        
        predictImage(image: image)
        photosCollectionView.reloadData()
    }
 
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPhotos.count
        } else {
            return photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoItemCollectionViewCell", for: indexPath) as! PhotoItemCollectionViewCell
        
        if isFiltering() {
            photoCell.photoImageView.image = filteredPhotos[indexPath.row].photo
        } else {
            photoCell.photoImageView.image = photos[indexPath.row].photo
        }
        return photoCell
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            predictImage(image: pickedImage)
            photosCollectionView.reloadData()
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}


extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            filterContentForSearchText(text)
        }
    }
}
