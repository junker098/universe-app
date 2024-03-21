//
//  PhotoModel.swift
//  Universe App
//
//  Created by Yuriy on 21.03.2024.
//

import Foundation

struct PhotoModel: Equatable {
    
    var localIdentifiers: String
    var isDeleting: Bool
    
    static func ==(lhs: PhotoModel, rhs: PhotoModel) -> Bool {
        lhs.localIdentifiers == rhs.localIdentifiers
    }
}
