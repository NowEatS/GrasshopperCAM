//
//  ViewController.swift
//  GrasshopperCAM
//
//  Created by TaeWon Seo on 2021/06/20.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet var cameraView: UIView!
    
    var session: AVCaptureSession!
    var output = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.layer.addSublayer(previewLayer)
        
        checkCameraPermissions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = cameraView.bounds
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            }
            catch {
                
            }
        }
    }
    
    @IBAction func didCaptureButtonTapped(_ sender: UIButton) {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        
        let image = UIImage(data: data)
        
        session.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = cameraView.bounds
        imageView.clipsToBounds = true
        cameraView.addSubview(imageView)
    }
    
}
