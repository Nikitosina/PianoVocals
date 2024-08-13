//
//  PianoViewModel.swift
//  PianoVocals
//
//  Created by Nikita Ratashnyuk on 12.08.2024.
//

import Foundation
import Pitchy1
import Beethoven_iOS

final class PianoViewModel: ObservableObject {
    private struct Constants {
        static let whiteIndexesInOctave = [0, 2, 4, 5, 7, 9, 11]
        static let blackIndexesInOctave = [1, 3, 6, 8, 10]
        static let letters: [Pitchy1.Note.Letter] = [
            .C,
            .CSharp,
            .D,
            .DSharp,
            .E,
            .F,
            .FSharp,
            .G,
            .GSharp,
            .A,
            .ASharp,
            .B
        ]
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
    @Published var pitchDetectionMode = false {
        didSet {
            if pitchDetectionMode {
                pitchDetector.start()
            } else {
                pitchDetector.stop()
                highlightedNote = nil
            }
            restartAudioEngine()
        }
    }
    @Published var highlightedNote: Note? = nil

    private let sound = PianoSound()
    private lazy var pitchDetector = PitchDetector(onPitchReceived: { [weak self] in
        guard let self else { return }
        highlightedNote = Note(octave: $0.octave + 1, letter: $0.letter.rawValue, keyNumber: noteToKey($0))
    })

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

    func restartAudioEngine() {
        sound.restartAudioEngine()
    }

    private func noteToKey(_ note: Pitchy1.Note) -> Int {
        (note.octave + 1) * 12 + note.letter.keyNumber
    }

    func numberToNote(_ number: Int) -> Note {
        let noteLetter = Constants.letters[number % 12]
        return Note(octave: number / 12, letter: noteLetter.rawValue, keyNumber: number)
    }
}

struct Note {
    var octave: Int
    var letter: String
    var keyNumber: Int
}
