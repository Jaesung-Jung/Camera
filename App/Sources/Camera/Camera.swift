//
//  Camera.swift
//
//  Copyright (c) 2017 Jaesung Jung.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import AVFoundation

final class Camera: NSObject {

    let session = AVCaptureSession()

    private(set) var position: AVCaptureDevice.Position

    private var camera: AVCaptureDevice
    private var microphone: AVCaptureDevice?

    private var videoOutput: AVCaptureVideoDataOutput!
    private var audioOutput: AVCaptureAudioDataOutput?

    private let sampleBufferQueue = DispatchQueue(label: "Camera.sampleBufferQueue")

    required init?(position: AVCaptureDevice.Position) {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            return nil
        }
        self.position = position
        self.camera = camera

        super.init()

        addVideoInputOutput(camera: camera)
    }

    deinit {
        session.stopRunning()
    }

}

extension Camera {

    func attachMicrophone() {
        guard microphone == nil else {
            return
        }

        guard let mic = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: position) else {
            return
        }
        let output = AVCaptureAudioDataOutput().then {
            $0.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        }

        addInput(device: mic)
        addOutput(output)

        microphone = mic
        audioOutput = output
    }

}

extension Camera {

    private func addVideoInputOutput(camera: AVCaptureDevice) {
        let output = AVCaptureVideoDataOutput().then {
            $0.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        }
        addInput(device: camera)
        addOutput(output)

        videoOutput = output
    }

    private func addInput(device: AVCaptureDevice) {
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
    }

    private func addOutput(_ output: AVCaptureOutput) {
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
    }

}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
    }

}

extension Camera: AVCaptureAudioDataOutputSampleBufferDelegate {
}
