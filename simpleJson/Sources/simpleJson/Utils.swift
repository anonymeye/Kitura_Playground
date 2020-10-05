//
//  File.swift
//  
//
//  Created by Abdel on 10/4/20.
//

import Foundation

extension String {
    func removingHTMLEncoding() -> String {
        let result = self.replacingOccurrences(of: "+", with: " ")
        return result.removingPercentEncoding ?? result }
}
