//
//  Enviornment.swift
//  DopamineFriends
//
//  Created by joki on 24.02.25.
//

import Foundation

class Environment {
    static let shared = Environment()
    private var config: [String : String] = [:]
    private init() {
        loadEnvFile()
    }
    
    private func loadEnvFile() {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil) else {
            print("Error .env file not found in bundle")
            return
        }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.split(separator: "\n")
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                    continue
                }
                let components = trimmedLine.split(separator: "=", maxSplits: 1)
                if components.count == 2 {
                    let key = components[0].trimmingCharacters(in: .whitespaces)
                    let value = components[1].trimmingCharacters(in: .whitespaces)
                    config[key] = value
                }
            }
        } catch {
            print("Error loading .env file: \(error)")
        }
    }
    
    func value(forKey key: String) -> String? {
        return config[key]
    }
}
