//
//  CoreGraphics.swift
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

import CoreGraphics

extension CGSize {

    func scaleFit(in rect: CGRect) -> CGSize {
        let ratio = min(rect.width / width, rect.height / height)
        let size = CGSize(
            width: floor(width * ratio),
            height: floor(height * ratio)
        )
        return size
    }

    func multiply(_ n: CGFloat) -> CGSize {
        return CGSize(width: width * n, height: height * n)
    }

}

extension CGRect {

    func scaleFit(in rect: CGRect) -> CGRect {
        let size = self.size.scaleFit(in: rect)
        let center = CGPoint(
            x: (rect.maxX - size.width) * 0.5,
            y: (rect.maxY - size.height) * 0.5
        )
        return CGRect(origin: center, size: size)
    }

}
