import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import WidgetKit

final class CameraViewController: UIViewController {

    @IBOutlet var cameraView: UIView!
    @IBOutlet var lensRotateButton: UIButton!
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var previewImageView: UIImageView!
    
    let disposeBag = DisposeBag()
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var output = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var rotatePosition: AVCaptureDevice.Position {
        guard let device = device else { return .back }
        return device.position == .front ? .back : .front
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewImageView.layer.cornerRadius = Constant.GHLayer.cornerRadius
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
                self.rotateCamera()
            }
            .disposed(by: disposeBag)

        captureButton.rx.controlEvent(.touchUpInside).asDriver()
            .drive() { [weak self] _ in
                guard let self = self else { return }
                self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
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
    
    // MARK: - 카메라 권한 및 설정
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self, granted else { return }
                DispatchQueue.main.async {
                    self.initializeCamera(with: .back)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            initializeCamera(with: .back)
        @unknown default:
            break
        }
    }
    
    private func initializeCamera(with position: AVCaptureDevice.Position) {
        let captureSession = AVCaptureSession()

        if let cameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
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

                captureSession.startRunning()

                self.session = captureSession
            } catch (let error) {
                print(error)
            }
        }
    }
    
    private func rotateCamera() {
        guard let currentCameraInput: AVCaptureInput = session.inputs.first else { return }
        
        session.beginConfiguration()
        session.removeInput(currentCameraInput)
        
        var device: AVCaptureDevice?
        
        if let input = currentCameraInput as? AVCaptureDeviceInput {
            device = input.device.position == .back ? makeCameraWithPosition(position: .front) : makeCameraWithPosition(position: .back)
        }
        
        var newCameraInput: AVCaptureDeviceInput?
        
        do {
            guard let newCamera = device else { return }
            
            newCameraInput = try AVCaptureDeviceInput(device: newCamera)
        } catch let error as NSError {
            print(error.localizedDescription)
            
            newCameraInput = nil
        }
        
        guard let input = newCameraInput else { return }
        
        session.addInput(input)
        session.commitConfiguration()
    }
    
    private func makeCameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: .unspecified
        )
        
        return discoverySession.devices.first(where: { $0.position == position })
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        
        let image = UIImage(data: data)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = cameraView.bounds
        imageView.clipsToBounds = true
        cameraView.addSubview(imageView)
        
        previewImageView.image = image
        
        UserDefaults.shared.setValue(data, forKey: GHUserDefaultsKeys.latestImage.rawValue)
        WidgetCenter.shared.reloadAllTimelines()
        
        UIView.animate(withDuration: 0.5) {
            imageView.alpha = 0
        } completion: { _ in
            imageView.removeFromSuperview()
        }
    }
    
}
