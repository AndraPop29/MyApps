//
//  ViewController.swift
//  sharing
//
//  Created by Andra on 04/12/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKMessengerShareKit
import MobileCoreServices
import TwitterKit

class FBViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentInteractionControllerDelegate  {
    
    private let kInstagramURL = "instagram://"
    private let kUTI = "com.instagram.exclusivegram"
    private let kfileNameExtension = "instagram.igo"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    var documentInteractionController = UIDocumentInteractionController()
    var type : String?
    var shareTo : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    func setupButtons() {
        let btn = UIButton()
        btn.frame = CGRect(origin: CGPoint(x: 115, y: 100), size: CGSize(width: 150, height: 50))
        btn.addTarget(self, action: #selector(showPhotoActionSheet), for: .touchUpInside)
        btn.setTitle("photo", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 10
        self.view.addSubview(btn)
        
        let btn2 = UIButton()
        btn2.frame = CGRect(origin: CGPoint(x: 115, y: 180), size: CGSize(width: 150, height: 50))
        btn2.addTarget(self, action: #selector(showVideoActionSheet(sender:)), for: .touchUpInside)
        btn2.setTitle("video", for: .normal)
        btn2.setTitleColor(.blue, for: .normal)
        btn2.layer.borderColor = UIColor.gray.cgColor
        btn2.layer.borderWidth = 1
        btn2.layer.cornerRadius = 10
        self.view.addSubview(btn2)
        
        
        let btn3 = UIButton()
        btn3.frame = CGRect(origin: CGPoint(x: 115, y: 260), size: CGSize(width: 150, height: 50))
        btn3.addTarget(self, action: #selector(showMessageActionSheet(sender:)), for: .touchUpInside)
        btn3.setTitle("random message", for: .normal)
        btn3.setTitleColor(.blue, for: .normal)
        btn3.layer.borderColor = UIColor.gray.cgColor
        btn3.layer.borderWidth = 1
        btn3.layer.cornerRadius = 10
        self.view.addSubview(btn3)
    }
    
    @objc func showMessageActionSheet(sender: UIButton) {
        
        let actionSheet: UIAlertController = UIAlertController(title: "Share "+sender.titleLabel!.text!, message: "Where would you like to share to?", preferredStyle: .actionSheet)
        let action1: UIAlertAction = UIAlertAction(title: "Facebook", style: .default, handler:{(action:UIAlertAction!) -> Void in
            self.shareTo = "facebook"
            self.shareRandomMessage()
        })
        
        let action2: UIAlertAction = UIAlertAction(title: "Twitter", style: .default, handler:{(action:UIAlertAction!) -> Void in
            self.shareTo = "twitter"
            self.shareRandomMessage()
        })
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        present(actionSheet, animated: true, completion:nil)
    }
    @objc func showVideoActionSheet(sender: UIButton) {
        let actionSheet: UIAlertController = UIAlertController(title: "Share "+sender.titleLabel!.text!, message: "Where would you like to share to?", preferredStyle: .actionSheet)
        let action1: UIAlertAction = UIAlertAction(title: "Facebook", style: .default, handler:{(action:UIAlertAction!) -> Void in
            self.shareTo = "facebook"
            self.shareFromPhotoLibrary(mediaType: sender.titleLabel!.text!)
        })
        
        actionSheet.addAction(action1)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        present(actionSheet, animated: true, completion:nil)

    }
 
    
    @objc func showPhotoActionSheet(sender: UIButton) {
        
        let actionSheet: UIAlertController = UIAlertController(title: "Share "+sender.titleLabel!.text!, message: "Where would you like to share to?", preferredStyle: .actionSheet)
        let action1: UIAlertAction = UIAlertAction(title: "Facebook", style: .default, handler:{(action:UIAlertAction!) -> Void in
            self.shareTo = "facebook"
            self.shareFromPhotoLibrary(mediaType: sender.titleLabel!.text!)
        })
        
        let action2: UIAlertAction = UIAlertAction(title: "Instagram", style: .default, handler:{(action:UIAlertAction!) -> Void in
            self.shareTo = "instagram"
            self.shareFromPhotoLibrary(mediaType: sender.titleLabel!.text!)
        })
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        
        present(actionSheet, animated: true, completion:nil)
    }
    
    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIView) {
        // called to post image with caption to the instagram application

        let instagramURL = URL(string: kInstagramURL)

        if UIApplication.shared.canOpenURL(instagramURL!) {
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(kfileNameExtension)
            //let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            try? UIImageJPEGRepresentation(imageInstagram, 1.0)!.write(to: fileURL, options: .atomic)
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 612, height: 612))
            //let fileURL = NSURL.fileURLWithPath(Path)
            documentInteractionController.url = fileURL
            documentInteractionController.delegate = self
            documentInteractionController.uti = kUTI

            // adding caption for the image
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
        }
        else {

            // alert displayed when the instagram application is not available in the device
            UIAlertView(title: kAlertViewTitle, message: kAlertViewMessage, delegate:nil, cancelButtonTitle:"Ok").show()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        if type == "photo" {
            guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            if shareTo! == "facebook" {
                let photo = FBSDKSharePhoto()
                photo.image = selectedImage
                photo.isUserGenerated = true
                let content = FBSDKSharePhotoContent()
                content.photos = [photo]
                dismiss(animated: true, completion: nil)
                FBSDKShareDialog.show(from: self, with: content, delegate: nil)
            } else {
                dismiss(animated: true, completion: nil)
                postImageToInstagramWithCaption(imageInstagram: selectedImage, instagramCaption: "\(description)", view: self.view)
                
            }
        } else {
            let videoURL = info[UIImagePickerControllerReferenceURL] as? URL
            let video = FBSDKShareVideo()
            video.videoURL = videoURL
            let content = FBSDKShareVideoContent()
            content.video = video
            dismiss(animated: true, completion: nil)
            FBSDKShareDialog.show(from: self, with: content, delegate: nil)
        }


    }
    @objc func shareRandomMessage() {
        if shareTo == "facebook" {
            let content = FBSDKShareLinkContent()
            FBSDKShareDialog.show(from: self, with: content, delegate: nil)
        } else {
            let composer = TWTRComposer()
            
            composer.setText("just setting up my Twitter Kit")
            composer.setImage(UIImage(named: "twitterkit"))
            composer.show(from: self) { result in
                if (result == .done) {
                    print("Successfully composed Tweet")
                } else {
                    print("Cancelled composing")
                }
            }
            
        }
     
    }
    func shareFromPhotoLibrary(mediaType: String) {
        let imagePickerController = UIImagePickerController()
        if mediaType == "photo" {
            type = "photo"
        } else {
            type = "video"
            imagePickerController.mediaTypes = [kUTTypeMovie as String]
        }
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

}


