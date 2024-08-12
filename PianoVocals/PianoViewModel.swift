//
//  PianoViewModel.swift
//  PianoVocals
//
//  Created by Nikita Ratashnyuk on 12.08.2024.
//

import Foundation

final class PianoViewModel: ObservableObject {
    private struct Constants {
        static let whiteIndexesInOctave = [0, 2, 4, 5, 7, 9, 11]
        static let blackIndexesInOctave = [1, 3, 6, 8, 10]
    }

    @Published var allKeys: [KeyInfo] = {
        var result = [KeyInfo]()
        for i in 0...127 {
            switch i % 12 {
            case 1, 3, 6, 8, 10:
                result.append(KeyInfo(color: .black, n: i))
            default:
                result.append(KeyInfo(color: .white, n: i))
            }
        }
        return result
    }()
    @Published var scrollDisabled = true

    lazy var whiteKeys: [KeyInfo] = allKeys.filter { $0.color == .white }
    lazy var blackKeys: [KeyInfo] = allKeys.filter { $0.color == .black }

    private let sound = PianoSound()

    func whiteKeyIndex(octave: Int, i: Int) -> Int {
        return (octave * 12) + Constants.whiteIndexesInOctave[i]
    }

    func blackKeyIndex(octave: Int, i: Int) -> Int {
        return (octave * 12) + Constants.blackIndexesInOctave[i]
    }

    func playKey(at i: Int) {
        guard scrollDisabled else { return }
        sound.play(keyInfo: allKeys[i])
        allKeys[i].isPressed = true
    }

    func stopKey(at i: Int) {
        guard scrollDisabled else { return }
        sound.stop(keyInfo: allKeys[i])
        allKeys[i].isPressed = false
    }
}
