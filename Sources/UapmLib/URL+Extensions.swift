// Copyright 2023 Nomasystems S.L.

import Foundation

extension URL {
    var pathExtensions: String {
        var result = ""
        var url = self
        while url.pathExtension != "" {
            if result != "" {
                result += "."
            }
            result += url.pathExtension
            url = url.deletingPathExtension()
        }
        return result
    }
}
