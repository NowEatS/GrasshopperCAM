import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class CameraViewController: UIViewController {

    @IBOutlet var cameraView: UIView!
    @IBOutlet var lensRotateButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    
    let disposeBag = DisposeBag()
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var output = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var rotatePosition: AVCaptureDevice.Position {
        guard let device = device else { return .front }
        return device.position == .front ? .back : .front
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.layer.addSublayer(previewLayer)
        
        bind()
        checkCameraPermissions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = cameraView.bounds
    }
    
    private func bind() {
        lensRotateButton.rx.controlEvent(.touchUpInside).asDriver()
            .drive { [weak self] _ in
                guard let self = self else { return }
                self.setupCamera(with: self.rotatePosition)
            }
            .disposed(by: disposeBag)

        menuButton.rx.controlEvent(.touchUpInside).asDriver()
            .drive { [weak self] _ in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "menuVC")
                self?.present(vc, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self, granted else { return }
                DispatchQueue.main.async {
                    self.setupCamera(with: self.rotatePosition)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera(with: rotatePosition)
        @unknown default:
            break
        }
    }
    
    private func setupCamera(with position: AVCaptureDevice.Position) {
        let captureSession = AVCaptureSession()
        
        if let cameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            self.device = cameraDevice
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                
                if captureSession.canAddOutput(output) {
                    captureSession.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = captureSession
                
                session.startRunning()
                
                self.session = captureSession
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
