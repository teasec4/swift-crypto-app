//
//  PricePoint.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/2/25.
//
import Foundation

struct PricePoint: Identifiable, Equatable, Decodable {
    let id = UUID()
    let date: Date
    let price: Double
}

