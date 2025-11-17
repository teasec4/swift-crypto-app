//
//  NetworkLogger.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
import Foundation
import os

final class NetworkLogger {
    private let maxBodyLength = 400
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoAsyncAwait", category: "network")
    
    enum LogLevel {
        case debug
        case info
        case warning
        case error
    }
    
    func logRequest(url: URL) {
        logger.debug("🌐 [REQUEST] \(url.absoluteString, privacy: .public)")
    }
    
    func logResponse(url: URL, statusCode: Int, data: Data?, duration: TimeInterval) {
        // ✅ Определяем уровень логирования по статусу
        let level: LogLevel = statusCode >= 400 ? .error : .info
        
        var log = "✅ [RESPONSE] \(url.lastPathComponent)\n"
        log += "⏱️  Duration: \(String(format: "%.2fs", duration))\n"
        log += "📦  Status: \(statusCode)\n"
        
        if let data = data {
            let sizeKB = Double(data.count) / 1024.0
            log += "📏  Size: \(String(format: "%.1f", sizeKB)) KB\n"
            
            // ✅ Логируем body preview только для debug
            if shouldLogBodyPreview(statusCode: statusCode) {
                if let body = String(data: data, encoding: .utf8) {
                    let preview = body.count > maxBodyLength ? String(body.prefix(maxBodyLength)) + "..." : body
                    log += "🧾  Body Preview:\n\(preview)\n"
                }
            }
        }
        
        logAtLevel(level, log)
    }
    
    // ✅ Логируем ошибку с контекстом
    func logError(_ error: Error, url: URL, statusCode: Int? = nil) {
        var log = "❌ [ERROR] \(url.lastPathComponent)\n"
        log += "Error: \(error.localizedDescription)\n"
        
        if let statusCode = statusCode {
            log += "Status: \(statusCode)\n"
        }
        
        logger.error("\(log, privacy: .public)")
    }
    
    // ✅ Логируем retry попытки
    func logRetry(url: URL, attempt: Int, maxAttempts: Int) {
        logger.warning("🔄 [RETRY] \(url.lastPathComponent) - Attempt \(attempt)/\(maxAttempts)")
    }
    
    // MARK: - Private Helpers
    
    private func shouldLogBodyPreview(statusCode: Int) -> Bool {
        // Логируем body только для успешных запросов или для ошибок (для отладки)
        return statusCode < 400 || statusCode >= 500
    }
    
    private func logAtLevel(_ level: LogLevel, _ message: String) {
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        }
    }
}
