//
//  PhotoLibraryViewModel.swift
//  Universe App
//
//  Created by Yuriy on 19.03.2024.
//

import UIKit
import Combine

protocol PhotoLibraryViewModelProtocol {
    var photoService: PHPhotoServiceProtocol { get }
}

class PhotoLibraryViewModel: PhotoLibraryViewModelProtocol {
    
    var photoService: PHPhotoServiceProtocol
    
    let photoPublisher = PassthroughSubject<UIImage?, Never>()
    let trashCount = PassthroughSubject<String?, Never>()
    var cancellables = Set<AnyCancellable>()
    
    private var photosArray: [PhotoModel] = []
    private var currentPhoto: PhotoModel?
    
    init(photoService: PHPhotoServiceProtocol) {
        self.photoService = photoService
    }
    
    func startLoading() {
        photoService.requestAutorization { [weak self] status in
            guard let strongSelf = self else { return }
            switch status {
            case .authorized:
                strongSelf.photoService.fetchAllPhotos { photoArray in
                    strongSelf.photosArray = photoArray
                    strongSelf.setupCurrentPhoto(photo: photoArray)
                }
            case .denied, .restricted, .limited:
                print("Photo access permission denied")
            case .notDetermined:
                print("Photo access permission not determined")
            @unknown default:
                break
            }
        }
    }
    
    private func setupCurrentPhoto(photo models: [PhotoModel]) {
        if let currentPhoto = models.first {
            self.currentPhoto = currentPhoto
            self.showPhoto(currentPhoto)
        }
    }
    
    private func showPhoto(_ info: PhotoModel?) {
        if let id = info?.localIdentifiers {
            Task {
                do {
                    if let image = try await photoService.fetchImage(byLocalIdentifier: id) {
                        photoPublisher.send(image)
                    } else {
                        showBlankPhoto()
                    }
                } catch {
                    print("Error fetching image: \(error)")
                }
            }
        } else {
            print("DEEBUG - showPhoto")
        }
    }
    
    func deleteTapped() {
        if let curPhoto = currentPhoto, let indexElement = photosArray.firstIndex(of: curPhoto) {
            photosArray[indexElement].isDeleting = true
            showNext()
            updateTrashCount()
        }
    }
    
    private func updateTrashCount() {
        trashCount.send(String(deletingCount()))
    }
    
    func deletingCount() -> Int {
        photosArray.filter { $0.isDeleting }.count
    }
    
    func showNext() {
        guard let curPhoto = currentPhoto, let currentPhotoIndex = photosArray.firstIndex(of: curPhoto) else {
            return
        }
        let nextIndex = photosArray.index(after: currentPhotoIndex)
        if nextIndex < photosArray.count {
            let nextPhoto = photosArray[nextIndex]
            showPhoto(nextPhoto)
            currentPhoto = nextPhoto
        } else {
            showBlankPhoto()
        }
    }
    
    func emptyTrash(result: @escaping (Result<String, Error>) -> Void) {
        photoService.deleteSelectedPhotos(photos: photosArray) { result($0) }
    }
    
    private func showBlankPhoto() {
        currentPhoto = nil
        photoPublisher.send(nil)
    }
}
