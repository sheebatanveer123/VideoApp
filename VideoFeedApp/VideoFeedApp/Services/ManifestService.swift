//
//  ManifestService.swift
//  VideoFeedApp
//
//  Created by Sheeba Tanveer on 2025-10-04.
//


import Foundation

protocol ManifestProviding {
    func fetchManifest(from url: URL) async throws -> Manifest
}

final class ManifestService: ManifestProviding {
    func fetchManifest(from url: URL) async throws -> Manifest {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode(Manifest.self, from: data)
    }
}
