//
//  CustomUIImageView.swift
//  instigo
//
//  Created by Omar Khaled on 18/04/2022.
//

import UIKit

class CustomUIImageView: UIImageView {
    
    var currentProcessingURL:String?
    var cachedImages:[String:UIImage] = [:]
    
    func loadImagFromURL(imageUrl:String){
        self.currentProcessingURL = imageUrl
        
        guard let url = URL(string: imageUrl) else { return }
        
        self.image = nil
        
        if let image = self.cachedImages[url.absoluteString] {
            self.image = image
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("error in the user url", error.localizedDescription)
                return
            }
            
            guard let currentUrl = response?.url?.absoluteString else {return}
            
            if currentUrl != self.currentProcessingURL {
                return
            }
            
            guard let data = data else {
                return
            }
            
            let image = UIImage(data: data)
            
            self.cachedImages[currentUrl] = image
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }

}
