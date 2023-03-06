//
//  ImageSaver.swift
//  InstaFilter
//
//  Created by Bahadır Ersin on 5.03.2023.
//

import UIKit

class ImageSaver:NSObject{
    
    func writeToPhotoAlbum(image:UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image:UIImage, didFinishSavingWithError error:Error?, contextInfo: UnsafeRawPointer){
        print("Save Finished!")
    }
}
