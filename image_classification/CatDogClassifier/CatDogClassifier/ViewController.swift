//
//  ViewController.swift
//  CatDogClassifier
//
//  Created by Vincent on 24/02/2019.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import AVKit
import CoreML
import Vision

enum Animal: String {
    case cat = "cat"
    case dog = "dog"
}

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var predictionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCapture()
    }
    
    func configureCapture() {
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.startRunning()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(captureInput)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let catDogModel = try? VNCoreMLModel(for: CatDog().model) else { return }
        
        let request =  VNCoreMLRequest(model: catDogModel) { (finishedRequest, err) in
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            
            guard let firstResult = results.first else { return }
            
            var predictionString = ""
            
            DispatchQueue.main.async {
                switch firstResult.identifier {
                case Animal.cat.rawValue:
                    predictionString = "Cat 🐈"
                case Animal.dog.rawValue:
                    predictionString = "Dog 🐕"
                default:
                    break
                }
                
                self.predictionLabel.text = predictionString + "(\(firstResult.confidence))"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

