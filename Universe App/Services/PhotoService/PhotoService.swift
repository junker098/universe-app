//
//  PhotoService.swift
//  Universe App
//
//  Created by Yuriy on 21.03.2024.
//

import Foundation
import UIKit
import Photos

protocol PHPhotoServiceProtocol {
    
    func requestAutorization(result: @escaping(PHAuthorizationStatus) -> Void)
    func fetchAllPhotos(result: @escaping([PhotoModel]) -> Void)
    func fetchImage(byLocalIdentifier localId: String) async throws -> UIImage?
    func deleteSelectedPhotos(photos: [PhotoModel], result: @escaping (Result<String, Error>) -> Void)
    
}

class PHPhotoService: PHPhotoServiceProtocol {
    
    var imageCachingManager = PHCachingImageManager()
    
    func requestAutorization(result: @escaping(PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { result($0) }
    }
    
    func fetchAllPhotos(result: @escaping([PhotoModel]) -> Void) {
        imageCachingManager.allowsCachingHighQualityImages = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                         ascending: false)
        ]
        var photosArray:[PhotoModel] = []
        DispatchQueue.global().async {
            let phetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            phetchResult.enumerateObjects({asset, _ , _ in
                let photoInfo = PhotoModel(localIdentifiers: asset.localIdentifier, isDeleting: false)
                photosArray.append(photoInfo)
            })
            
            result(photosArray)
        }
    }
    
    func fetchImage(byLocalIdentifier localId: String) async throws -> UIImage? {
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
        guard let asset = results.firstObject else {throw PHPhotosError(_nsError: NSError(domain: "Photo Error", code: 2))}
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else { return }
            self.imageCachingManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .default,
                options: options,
                resultHandler: { image, info in
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        DebugLogger.shared.logEvent(type: .error, object: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }
    
    func deleteSelectedPhotos(photos: [PhotoModel], result: @escaping (Result<String, Error>) -> Void) {
        let identefiersToDelete = photos.filter({ $0.isDeleting }).map { $0.localIdentifiers }
        guard !identefiersToDelete.isEmpty else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: identefiersToDelete, options: nil)
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { success, error in
            if success {
                result(.success("\(identefiersToDelete.count) photos deleted"))
            } else {
                result(.failure(error ?? NSError()))
            }
        }
    }
}
