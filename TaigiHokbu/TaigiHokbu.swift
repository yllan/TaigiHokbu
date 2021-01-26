//
//  TaigiHokbu.swift
//  TaigiHokbu
//
//  Created by Yung-Luen Lan on 2021/1/25.
//

import Cocoa
import AVFoundation

struct SyntaxStructure : Decodable {
    var 漢字: String
    var KIP: String
    var 分詞: String
}

enum TaigiError : Error {
    case jsonFormatIncorrect
    case cannotEscapeString
    case cannotGetAudio
}

struct TaigiHokbu {
    
    static var player: AVAudioPlayer? = nil
    
    static func parseTaigi(_ taigi: String, callback: @escaping (Result<SyntaxStructure, Error>) -> Void) {
        if let taigiEncoded = taigi.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
           let url = URL(string: "https://hokbu.ithuan.tw/tau") {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.httpBody = "taibun=\(taigiEncoded)".data(using: .utf8)
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: req) { (data, response, error) in
                let decoder = JSONDecoder()
                if let error = error {
                    callback(.failure(error))
                } else if let data = data,
                   let syntaxStructure = try? decoder.decode(SyntaxStructure.self, from: data) {
                    callback(.success(syntaxStructure))
                } else {
                    callback(.failure(TaigiError.jsonFormatIncorrect))
                }
            }
            task.resume()
        } else {
            callback(.failure(TaigiError.cannotEscapeString))
        }
    }
    
    static func liamTaigi(_ kip: String, callback: @escaping (Result<Data, Error>) -> Void) {
        if let kipEncoded = kip.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
           let url = URL(string: "https://hapsing.ithuan.tw/bangtsam?taibun=\(kipEncoded)") {
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    callback(.success(data))
                } else {
                    callback(.failure(TaigiError.cannotGetAudio))
                }
            }
            task.resume()
        }
    }
}
