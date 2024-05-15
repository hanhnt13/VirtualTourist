//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by admin on 14/5/24.
//

import UIKit

struct SearchPhotoResponse: Codable {
    let stat: String
    let photos: Photos
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoInfo]
}

struct PhotoInfo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

struct SizesResponse:Codable {
    let stat: String
    let sizes: Sizes
}

struct Sizes:Codable {
    let canblog: Int
    let canprint: Int
    let candownload: Int
    let size: [PhotoSizes]
}

struct PhotoSizes:Codable {
    let label: String
    let width: Int
    let height: Int
    let source: String
    let url: String
    let media: String
}
