//
//  CameraPreviewView.swift
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

import UIKit
import MetalKit
import Cartography

class CameraPreviewView: UIView {

    private let metalView = MTKView()
    private var commandQueue: MTLCommandQueue?
    private var sourceTexture: MTLTexture?

    var device: MTLDevice? {
        get { return metalView.device }
        set {
            metalView.device = newValue
            commandQueue = newValue?.makeCommandQueue()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func draw(texture: MTLTexture) {
        sourceTexture = texture
        metalView.draw()
    }

}

extension CameraPreviewView: MTKViewDelegate {

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let currentDrawable = view.currentDrawable else {
            return
        }
        guard let texture = sourceTexture, let commandQueue = commandQueue else {
            return
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else {
            return
        }

        view.colorPixelFormat = texture.pixelFormat

        let rect = CGRect(x: 0, y: 0, width: texture.width, height: texture.height)
            .scaleFit(in: CGRect(
                origin: view.bounds.origin,
                size: view.bounds.size.multiply(UIScreen.main.scale)
            ))

        blitCommandEncoder.copy(
            from: texture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: .zero,
            sourceSize: MTLSize(width: Int(rect.width), height: Int(rect.height), depth: 1),
            to: currentDrawable.texture,
            destinationSlice: 0,
            destinationLevel: 0,
            destinationOrigin: MTLOrigin(x: Int(rect.origin.x), y: Int(rect.origin.y), z: 0)
        )
        blitCommandEncoder.endEncoding()

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

}

extension CameraPreviewView {

    private func setup() {
        metalView.delegate = self
        metalView.framebufferOnly = false
        metalView.isPaused = true

        addSubview(metalView)
        makeConstraint()
    }

    private func makeConstraint() {
        constrain(metalView) {
            $0.edges == $0.superview!.edges
        }
    }

}
