//
//  OrientViewController.swift
//  testAp
//
//  Created by Jack McCabe on 8/29/22.
//

import UIKit
import AVKit
import Photos
import PhotosUI
import AVFoundation

class OrientViewController: UIViewController, PHPickerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        presentPicker()
    }
    var assetComp = AVMutableComposition()
    var playerVC = AVPlayerViewController()
    
    private func getVideo(from itemProvider: NSItemProvider, typeIdentifier: String) {
        itemProvider.loadInPlaceFileRepresentation(forTypeIdentifier: typeIdentifier) {  url, bool, error in
   //  itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url,  error in

            var   playerAsset = AVAsset(url: url!)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            guard let targetURL = documentsDirectory?.appendingPathComponent(url!.lastPathComponent) else {print("could not append Path component"); return }
            do {
                if FileManager.default.fileExists(atPath: targetURL.path) {
                    try FileManager.default.removeItem(at: targetURL)
                }
                try FileManager.default.copyItem(at: url!, to: targetURL)
                self.createVideo(url:targetURL)
            } catch {
                print("Issue removing URL, \(error.localizedDescription)\n\(error)")
            }
        }
    }
    
    func createVideo(url:URL){
       var   playerAsset = AVAsset(url: url)

            do{
             var assetComp =   try assetComp.insertTimeRange(CMTimeRange(start: CMTime.zero, duration:CMTimeMakeWithSeconds(20.0, preferredTimescale: 1) ), of: playerAsset, at: CMTime.zero)
                
               }catch{
                   print("\(error.localizedDescription)")
                }
        var playerItem = AVPlayerItem(asset: assetComp)
        var player = AVPlayer(playerItem: playerItem)
        playerVC.player = player

        orientVideoWithoutExporting()
        DispatchQueue.main.async{
            self.view.addSubview(self.playerVC.view)
            player.play()
        }

        
        }
    
    func orientVideoWithoutExporting(){
        
        //Not sure how to orient without Exporting, exporting is way to computational expensive
        //I've tried this but it rotates everything including the controls and I'm stuck, can't get it to work on only the video
        //  playerController.view.transform = CGAffineTransform(rotationAngle: CGFloat(0.7))
    }
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        playerVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.8)
    }

}
extension OrientViewController{
    func presentPicker(){
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.selectionLimit = 1
    config.preferredAssetRepresentationMode = .current
    config.filter = .videos
    let vc = PHPickerViewController(configuration: config)
    vc.delegate = self
    present(vc, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach{ result in result.itemProvider.loadObject(ofClass: UIImage.self ) { reading, error in
            guard let typeIdentifier = result.itemProvider.registeredTypeIdentifiers.first, let utType = UTType(typeIdentifier)
            else { return}
            
            let itemProvider = result.itemProvider
            guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                  let utType = UTType(typeIdentifier) else {return}
            
            if utType.conforms(to: .movie) {
                self.getVideo(from: itemProvider, typeIdentifier: typeIdentifier); }else{
                }}         }
        
    }
}
