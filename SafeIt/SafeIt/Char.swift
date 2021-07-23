//
//  Char.swift
//  SafeIt
//
//  Created by Christina Pouli on 13/07/2021.
//

import UIKit
import RealityKit
import Combine

class Char{
    var charName: String
    var image: UIImage
    var charEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(charName: String){
        self.charName = charName
        self.image = UIImage(named: charName)!
        
        let filename = charName + ".usdz"
        
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                //Handle error
                print("DEBUG: unable to load charEntity for \(self.charName)")
            }, receiveValue: { charEntity in
                //get charEntity
                self.charEntity = charEntity
                print("DEBUG: succesfully loaded charEntity for \(self.charName)")
            })
            
        
    }
}
