//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftGRPC

public enum Result<Value>: CustomStringConvertible, CustomDebugStringConvertible {
    case success(Value)
    case failure(Error)
    
    public init(value: Value) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }
    
    init(value: Value?, error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
    
    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
    
    func map<U>(_ transform: (Value) -> U) -> Result<U> {
        return flatMap { .success(transform($0)) }
    }
    
    func flatMap<U>(_ transform: (Value) -> Result<U>) -> Result<U> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }

    public var description: String {
        switch self {
        case let .success(value):
            return ".success(\(value))"
        case let .failure(error):
            return ".failure(\(error))"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

/// Helper methods to create `Result` objects from grpc results

func result<T, U>(_ callback: @escaping (Result<U>) -> Void, map: @escaping (T) -> U?) -> (T?, CallResult) -> Void {
    return { (response: T?, callResult: CallResult) in
        if let response = response,
            let value = map(response) {
            callback(Result<U>(value: value))
        } else if !callResult.success {
            switch callResult.statusCode {
            case .unavailable:
                print(LndApiError.noInternet)
                callback(Result<U>(error: LndApiError.noInternet))
            default:
                if let statusMessage = callResult.statusMessage {
                    print(statusMessage)
                    callback(Result<U>(error: LndApiError.localizedError(statusMessage)))
                } else {
                    callback(Result<U>(error: LndApiError.unknownError))
                }
            }
        } else if let statusMessage = callResult.statusMessage {
            print(LndApiError.localizedError, callResult)
            callback(Result<U>(error: LndApiError.localizedError(statusMessage)))
        } else {
            print(LndApiError.unknownError, callResult)
            callback(Result<U>(error: LndApiError.unknownError))
        }
    }
}