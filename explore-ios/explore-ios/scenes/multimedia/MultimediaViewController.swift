//
//  MultimediaViewController.swift
//  explore-ios
//
//  Created by Andra on 09/01/2018.
//  Copyright © 2018 andrapop. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation

class MultimediaViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    let invisibleButton = UIButton()

    @objc func streamVideoButton(_ sender: Any) {
        let videoStreamURL = URL(string: "http://playertest.longtailvideo.com/adaptive/wowzaid3/playlist.m3u8")
       

        //        let player = AVPlayer(url: videoStreamURL!)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
    }
    @objc func viewVideoButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String]

        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    func setupButtons() {
        let btn = UIButton()
        btn.frame = CGRect(origin: CGPoint(x: 123, y: 100), size: CGSize(width: 130, height: 50))
        btn.addTarget(self, action: #selector(viewVideoButton(_:)), for: .touchUpInside)
        btn.setTitle("View video", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 10
        self.view.addSubview(btn)
        
        let btn2 = UIButton()
        btn2.frame = CGRect(origin: CGPoint(x: 123, y: 170), size: CGSize(width: 130, height: 50))
        btn2.addTarget(self, action: #selector(streamVideoButton(_:)), for: .touchUpInside)
        btn2.setTitle("Stream video", for: .normal)
        btn2.setTitleColor(.blue, for: .normal)
        btn2.layer.borderColor = UIColor.gray.cgColor
        btn2.layer.borderWidth = 1
        btn2.layer.cornerRadius = 10
        self.view.addSubview(btn2)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MULTIMEDIA"
        setupButtons()
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(invisibleButtonTapped),
                                  for: .touchUpInside)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avPlayerLayer.frame = CGRect(x: 0, y: 250, width: self.view.frame.width, height: self.view.frame.height / 2)
        invisibleButton.frame = CGRect(x: 0, y: 250, width: self.view.frame.width, height: self.view.frame.height / 2)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let videoURL = info[UIImagePickerControllerMediaURL] as? URL
        let playerItem = AVPlayerItem(url: videoURL!)
        avPlayer.replaceCurrentItem(with: playerItem)
        //let player = AVPlayer(url: videoURL! as URL)
        //let playerLayer = AVPlayerLayer(player: player)
        //playerLayer.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.height / 2)
        //self.view.layer.insertSublayer(playerLayer, at: 50)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
//
    }
    
    @objc func invisibleButtonTapped(sender: UIButton) {
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying {
            avPlayer.pause()
        } else {
            avPlayer.play()
        }
    }
    

}
