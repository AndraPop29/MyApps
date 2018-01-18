//
//  UploadPhotoViewController.swift
//  sharing
//
//  Created by Andra on 07/12/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import UIKit

class UploadPhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate {
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
    }
    @IBAction func compressImage(_ sender: Any) {
        compressImage()
    }
    @IBAction func uploadImageButton(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    func compressImage() -> UIImage {
        let oldImage = imageView.image
        var imageData = Data(UIImagePNGRepresentation(oldImage!)!)
        print("***** Uncompressed Size \(imageData.description) **** ")
        
        imageData = UIImageJPEGRepresentation(oldImage!, 0.025)!
        print("***** Compressed Size \(imageData.description) **** ")
        
        let image = UIImage(data: imageData)
        imageView.image = image
        return image!
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
