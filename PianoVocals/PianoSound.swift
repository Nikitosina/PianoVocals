//
//  SineWave.swift
//  PianoSample
//
//  Created by Takuto Nakamura on 2020/09/11.
//  Copyright © 2020 Takuto Nakamura. All rights reserved.
//

import AVFoundation
import SwiftUI

class PianoSound {

    private let audioEngine = AVAudioEngine()
    private let unitSampler = AVAudioUnitSampler()

    init(volume: Float = 1) {
        audioEngine.mainMixerNode.volume = volume
        audioEngine.attach(unitSampler)
        audioEngine.connect(unitSampler, to: audioEngine.mainMixerNode, format: nil)
        if let _ = try? audioEngine.start() {
            loadSoundFont()
        }
    }

    deinit {
        if audioEngine.isRunning {
            audioEngine.disconnectNodeOutput(unitSampler)
            audioEngine.detach(unitSampler)
            audioEngine.stop()
        }
    }

    private func loadSoundFont() {
        guard let url = Bundle.main.url(forResource: "emuaps_8mb",
                                        withExtension: "sf2") else { return }
        try? unitSampler.loadSoundBankInstrument(
            at: url, program: 0,
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
    }

    private func makeWhiteNotes(_ n: Int) -> [UInt8] {
        if n < 0 {
            fatalError("bad request")
        } else if n == 0 {
            return [0]
        } else if n % 7 == 0 || n % 7 == 3 {
            let notes = makeWhiteNotes(n - 1)
            return notes + [notes.last! + 1]
        } else {
            let notes = makeWhiteNotes(n - 1)
            return notes + [notes.last! + 2]
        }
    }

    private func mekeBlackNotes(_ n: Int) -> [UInt8] {
        if n < 0 {
            fatalError("bad request")
        } else if n == 0 {
            return [1]
        } else if n % 7 == 2 || n % 7 == 6 {
            let notes = mekeBlackNotes(n - 1)
            return notes + [notes.last! + 1]
        } else {
            let notes = mekeBlackNotes(n - 1)
            return notes + [notes.last! + 2]
        }
    }

    func play(keyInfo: KeyInfo) {
        let note = UInt8(keyInfo.n)
        self.unitSampler.startNote(note, withVelocity: 127, onChannel: 0)
    }

    func stop(keyInfo: KeyInfo) {
        let note = UInt8(keyInfo.n)
        self.unitSampler.stopNote(note, onChannel: 0)
    }

    func restartAudioEngine() {
        if let _ = try? audioEngine.start() {
            loadSoundFont()
        }
    }

}

enum KeyColor {
    case white
    case black

    var description: String {
        switch self {
        case .white: return "white"
        case .black: return "black"
        }
    }

    func value(isPressed: Bool) -> Color {
        switch self {
        case .white: return isPressed ? Color(white: 0.8) : .white
        case .black: return isPressed ? Color(white: 0.2) : .black
        }
    }
}

struct KeyInfo {
    let color: KeyColor
    let n: Int
    var isPressed: Bool = false

    var description: String {
        return "\(color.description), \(n): \(isPressed)"
    }
}
