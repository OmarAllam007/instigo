//
//  selectPhotoViewController.swift
//  instigo
//
//  Created by Omar Khaled on 17/04/2022.
//

import UIKit
import Photos

private let photocellID = "photoCellId"
private let headerlID = "headerCellId"

class SelectPhotoViewController: UICollectionViewController,
UICollectionViewDelegateFlowLayout{

    var selectedImage:UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.collectionView!.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: photocellID)
        
        
        self.collectionView.register(PhotosHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerlID)
        
        setupNavigationBar()
        
        loadPhotos()
    }
    
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    private func loadPhotos(){
        let options = PHFetchOptions()
        options.fetchLimit = 30
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
       let allPhotos =  PHAsset.fetchAssets(with: .image, options: options)
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { asset, count, stop in
                let imageManager = PHImageManager()
                let size = CGSize(width: 300, height: 300)
                
                let options = PHImageRequestOptions()
            
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { image, info in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView.reloadData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    // header view
    var header:PhotosHeaderCollectionViewCell?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerlID, for: indexPath) as! PhotosHeaderCollectionViewCell
        
        self.header = header
        
        if let selectedImage = selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let size = CGSize(width: 600, height: 600)
                
                imageManager.requestImage(for: selectedAsset, targetSize: size, contentMode: .default, options: nil) { image, info in
                    header.imageView.image = image
                }
            }
 
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photocellID, for: indexPath)
        as! PhotoCollectionViewCell
        
        cell.imageView.image = images[indexPath.item]
        
        return cell
    }


    
    // MARK: - custom functions
    
    
    fileprivate func setupNavigationBar(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc fileprivate func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    

    @objc fileprivate func handleNext(){
        let sharePostViewController = SharePostViewController()
        sharePostViewController.selectedImage = self.header?.imageView.image
        navigationController?.pushViewController(sharePostViewController, animated: true)
    }

    
}
