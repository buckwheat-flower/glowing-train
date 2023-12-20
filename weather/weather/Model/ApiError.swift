//
//  ApiError.swift
//  weather
//
//  Created by 1 on 11/20/23.
//

import Foundation

enum ApiError: Error {
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}
