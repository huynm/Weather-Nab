//
//  String+Trimming.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

extension String {
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
