//
//  NetworkLogger.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
import Foundation
import os

final class NetworkLogger{
    private let maxBodyLength = 400
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoAsyncAwait", category: "network")
    
    func logRequest(url: URL){
        logger.debug("🌐 [REQUEST] \(url.absoluteString, privacy: .public)")
    }
    
    func logResponse(url: URL, statusCode: Int, data: Data?, duration:TimeInterval){
        var log = "✅ [RESPONSE] \(url.lastPathComponent)\n"
        log += "⏱️  Duration: \(String(format: "%.2fs", duration))\n"
        log += "📦  Status: \(statusCode)\n"
        
        if let data = data {
            let sizeKB = Double(data.count) / 1024.0
            log += "📏  Size: \(String(format: "%.1f", sizeKB)) KB\n"
            if let body = String(data: data, encoding: .utf8) {
                let preview = body.count > maxBodyLength ? String(body.prefix(maxBodyLength)) + "..." : body
                log += "🧾  Body Preview:\n\(preview)\n"
            }
        }
        
        logger.debug("\(log, privacy: .public)")
    }
}
