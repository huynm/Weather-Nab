//
//  Coordinator.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

protocol Coordinator {
    associatedtype Route
    
    func trigger(_ route: Route)
}
