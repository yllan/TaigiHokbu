//
//  ViewController.swift
//  TaigiHokbu
//
//  Created by Yung-Luen Lan on 2021/1/25.
//

import Cocoa
import GameKit
import AVKit

class ViewState: GKState {
    unowned let viewController: ViewController
    init(viewController: ViewController) {
        self.viewController = viewController
    }
}

class EmptyState : ViewState {
    override func didEnter(from previousState: GKState?) {
        self.viewController.searchField.stringValue = ""
        self.viewController.resultField.stringValue = ""
        self.viewController.searchButton.isEnabled = true
    }
}
class LoadingState : ViewState {
    var searchTerm: String = ""
    
    override func didEnter(from previousState: GKState?) {
        self.viewController.resultField.stringValue = ""
        self.viewController.searchButton.isEnabled = false
        
        TaigiHokbu.parseTaigi(searchTerm) { result in
            switch result {
            case .success(let s):
                if let fetchState = self.viewController.stateMachine?.state(forClass: FetchingAudioState.self) {
                    fetchState.searchTerm = self.searchTerm
                    fetchState.syntaxStructure = s
                    self.viewController.stateMachine?.enter(FetchingAudioState.self)
                }
            case .failure(let e):
                self.viewController.stateMachine?.state(forClass: ErrorState.self)?.error = e
                self.viewController.stateMachine?.enter(ErrorState.self)
            }
        }
    }
}
class FetchingAudioState : ViewState {
    var searchTerm: String = ""
    var syntaxStructure: SyntaxStructure = SyntaxStructure(漢字: "", KIP: "", 分詞: "")
    
    override func didEnter(from previousState: GKState?) {
        DispatchQueue.main.async {
            let result = NSMutableAttributedString()
            result.append(NSAttributedString(string: "漢字\n", attributes: [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 14)]))
            result.append(NSAttributedString(string: self.syntaxStructure.漢字 + "\n\n", attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13)]))
            result.append(NSAttributedString(string: "教育部台羅\n", attributes: [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 14)]))
            result.append(NSAttributedString(string: self.syntaxStructure.KIP, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13)]))
            
            self.viewController.resultField.attributedStringValue = result
            self.viewController.searchButton.isEnabled = true
        }
        TaigiHokbu.liamTaigi(syntaxStructure.KIP) { (result) in
            switch result {
            case .success(let data):
                let doneState = self.viewController.stateMachine!.state(forClass: DoneState.self)!
                doneState.searchTerm = self.searchTerm
                doneState.syntaxStructure = self.syntaxStructure
                doneState.mp3Data = data
                self.viewController.stateMachine?.enter(DoneState.self)
            case .failure(let e):
                self.viewController.stateMachine?.state(forClass: ErrorState.self)?.error = e
                self.viewController.stateMachine?.enter(ErrorState.self)
                
            }
        }
    }
}

class DoneState : ViewState {
    var searchTerm: String = ""
    var syntaxStructure = SyntaxStructure(漢字: "", KIP: "", 分詞: "")
    var mp3Data = Data()
    
    override func didEnter(from previousState: GKState?) {
        do {
            self.viewController.player = try AVAudioPlayer(data: mp3Data)
            self.viewController.player?.prepareToPlay()
            self.viewController.player?.volume = 1.0
            self.viewController.player?.play()
        } catch let error {
            self.viewController.stateMachine?.state(forClass: ErrorState.self)?.error = error
            self.viewController.stateMachine?.enter(ErrorState.self)
        }
        
    }
}

class ErrorState : ViewState {
    var error: Error? = nil
}

class ViewController: NSViewController {

    var stateMachine: GKStateMachine?
    var player: AVAudioPlayer? = nil
    
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var resultField: NSTextField!
    
    override func awakeFromNib() {
        stateMachine = GKStateMachine(states: [
            EmptyState(viewController: self),
            LoadingState(viewController: self),
            FetchingAudioState(viewController: self),
            DoneState(viewController: self),
            ErrorState(viewController: self)
        ])
        stateMachine?.enter(EmptyState.self)
    }
    
    @IBAction func search(_ sender: Any) {
        let str = searchField.stringValue
        stateMachine?.state(forClass: LoadingState.self)?.searchTerm = str
        stateMachine?.enter(LoadingState.self)
    }
    
    @objc func speakTaigi(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
        // get the string
        if let taigi = pboard.string(forType: .string) {
            self.searchField.stringValue = taigi
            self.search(self.searchButton!)
        }
    }
}

