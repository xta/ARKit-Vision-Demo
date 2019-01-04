//
//  ViewController.swift
//  ARKit Vision Demo
//
//  Created by Rex on 1/4/19.
//  Copyright © 2019 Dev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var faceDetectionRequest: VNRequest!
    var requests = [VNRequest]()
    
    var currentBuffer: CVPixelBuffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Face detection
        sceneView.session.delegate = self
        faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaces)
        self.requests = [faceDetectionRequest]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        self.currentBuffer = frame.capturedImage
        
        classifyCurrentImage()
    }

    // MARK: - Vision usage
    
    func classifyCurrentImage() {
        guard let buffer = currentBuffer else { return }
       
        let image = CIImage(cvPixelBuffer: buffer)
        let options: [VNImageOption: Any] = [:]
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, orientation: self.imageOrientation, options: options)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNFaceObservation] else { return }
            // TODO - something here with results
            print(results)
            
            self.currentBuffer = nil
        }
    }

    private var imageOrientation: CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .portrait: return .right
        case .landscapeRight: return .down
        case .portraitUpsideDown: return .left
        case .unknown: fallthrough
        case .faceUp: fallthrough
        case .faceDown: fallthrough
        case .landscapeLeft: return .up
        }
    }
    
}
