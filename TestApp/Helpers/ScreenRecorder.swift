//
//  ScreenRecorder.swift
//  TestApp
//
//  Created by Никита Лужбин on 09.01.2025.
//

import AVFoundation
import AVKit

final class ScreenRecorder {
    private var displayLink: CADisplayLink?
    private var writer: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var startTime: CMTime?
    
    private let outputURL: URL
    private var viewToRecord: UIView?
    private var viewSize: CGSize = .zero
    
    init(outputURL: URL) {
        self.outputURL = outputURL
    }
    
    func startRecording(view: UIView) throws {
        self.viewToRecord = view
        self.viewSize = view.bounds.size
        
        // Prepare writer
        writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: viewSize.width,
            AVVideoHeightKey: viewSize.height
        ]
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        videoInput?.expectsMediaDataInRealTime = true
        
        guard let writer = writer, writer.canAdd(videoInput!) else { throw NSError(domain: "Cannot add video input", code: -1) }
        writer.add(videoInput!)
        
        // Set up pixel buffer adaptor
        let bufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: viewSize.width,
            kCVPixelBufferHeightKey as String: viewSize.height
        ]
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput!, sourcePixelBufferAttributes: bufferAttributes)
        
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        // Set up display link
        displayLink = CADisplayLink(target: self, selector: #selector(captureFrame))
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.preferredFramesPerSecond = 60
        startTime = nil
    }
    
    func stopRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        displayLink?.invalidate()
        displayLink = nil
        
        videoInput?.markAsFinished()
        writer?.finishWriting {
            if let writer = self.writer, writer.status == .completed {
                completion(.success(self.outputURL))
            } else {
                completion(.failure(self.writer?.error ?? NSError(domain: "Unknown error", code: -1)))
            }
        }
    }
    
    @objc private func captureFrame() {
        guard let writer = writer, let videoInput = videoInput, let pixelBufferAdaptor = pixelBufferAdaptor else { return }
        guard videoInput.isReadyForMoreMediaData else { return }
        
        if startTime == nil, let timestamp = displayLink?.timestamp {
            startTime = CMTime(seconds: timestamp, preferredTimescale: 1000)
        }
        guard let time = displayLink?.timestamp, let startTime = startTime else { return }
        let presentationTime = CMTime(seconds: time - startTime.seconds, preferredTimescale: 1000)
        
        guard let view = viewToRecord else { return }
        guard let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool else { return }
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBuffer)
        
        guard let buffer = pixelBuffer else { return }
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(viewSize.width),
            height: Int(viewSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        // Flip the context vertically
        context?.translateBy(x: 0, y: viewSize.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        view.layer.render(in: context!)
        UIGraphicsPopContext()
        
        pixelBufferAdaptor.append(buffer, withPresentationTime: presentationTime)
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
    }
}
