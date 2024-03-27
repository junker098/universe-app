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
    var coreDataService: CoreDataServiceProtocol { get }
}

class PhotoLibraryViewModel: PhotoLibraryViewModelProtocol {
    
    enum PublisherEvent {
        case errorMessage(String)
        case photoPublisher(UIImage?)
        case trashCount(String?)
    }
    
    var photoService: PHPhotoServiceProtocol
    var coreDataService: CoreDataServiceProtocol
    
    var publisher = PassthroughSubject<PublisherEvent, Never>()
    var cancellables = Set<AnyCancellable>()
    
    private var photosArray: [PhotoModel] = []
    private var currentPhoto: PhotoModel?
    
    init(photoService: PHPhotoServiceProtocol, coreDataService: CoreDataServiceProtocol) {
        self.photoService = photoService
        self.coreDataService = coreDataService
        addSubscriber()
    }
    
    func addSubscriber() {
        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                guard let self else { return }
                self.coreDataService.saveNewModels(self.photosArray)
            }
            .store(in: &cancellables)
    }
    
    func startLoading() {
        photoService.requestAutorization { [weak self] status in
            guard let self else { return }
            switch status {
            case .authorized:
                self.photoService.fetchAllPhotos { photoArray in
                    self.checkSavedData(new: photoArray)
                }
            case .denied, .restricted, .limited:
                self.sendAlert(text: "Photo access permission denied")
            case .notDetermined:
                self.sendAlert(text: "Photo access permission not determined")
            @unknown default:
                break
            }
        }
    }
    
    func checkSavedData(new model: [PhotoModel]) {
        coreDataService.fetchPhotoModels { data in
            self.photosArray = model
            if let oldData = data {
                oldData.forEach { coreDataModel in
                    if coreDataModel.isDeleting {
                        if let index = model.firstIndex(where: { $0.localIdentifiers == coreDataModel.localIdentifiers }) {
                            self.photosArray[index].isDeleting = coreDataModel.isDeleting
                        }
                    }
                }
            }
            self.setupCurrentPhoto(self.photosArray)
            self.updateTrashCount()
        }
    }
    
    private func setupCurrentPhoto(_ models: [PhotoModel]) {
        if let currentPhoto = models.first(where: { !$0.isDeleting }) {
            self.currentPhoto = currentPhoto
            self.showPhoto(currentPhoto)
        }
    }
    
    private func showPhoto(_ model: PhotoModel?) {
        if let id = model?.localIdentifiers {
            Task {
                do {
                    if let image = try await photoService.fetchImage(byLocalIdentifier: id) {
                        publisher.send(.photoPublisher(image))
                    } else {
                        showBlankPhoto()
                    }
                } catch {
                    sendAlert(text: "Error fetching image: \(error)")
                }
            }
        } else {
            showBlankPhoto()
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
        publisher.send(.trashCount(String(deletingCount())))
    }
    
    func deletingCount() -> Int {
        photosArray.filter { $0.isDeleting }.count
    }
    
    func showNext() {
        guard let curPhoto = currentPhoto, let currentPhotoIndex = photosArray.firstIndex(of: curPhoto) else {
            return
        }
        var nextIndex = currentPhotoIndex
        
        repeat {
            nextIndex = photosArray.index(after: nextIndex)
        } while nextIndex < photosArray.count && photosArray[nextIndex].isDeleting
        
        if nextIndex < photosArray.count {
            let nextPhoto = photosArray[nextIndex]
            showPhoto(nextPhoto)
            currentPhoto = nextPhoto
        } else {
            showBlankPhoto()
        }
    }
    
    func emptyTrash(result: @escaping (Result<String, Error>) -> Void) {
        photoService.deleteSelectedPhotos(photos: photosArray) { [weak self] responseResult in
            guard let self else { return }
            switch responseResult {
            case .success(_ ):
                self.photosArray.removeAll { $0.isDeleting }
                self.updateTrashCount()
            default: break
            }
            result(responseResult)
        }
    }
    
    private func showBlankPhoto() {
        currentPhoto = nil
        publisher.send(.photoPublisher(nil))
    }
    
    private func sendAlert(text: String?) {
        publisher.send(.errorMessage(text ?? "Error"))
    }
}
