//
//  PitchDetector.swift
//  PianoVocals
//
//  Created by Nikita Ratashnyuk on 12.08.2024.
//

import Pitchy1
import Beethoven_iOS

final class PitchDetector {
    private lazy var pitchEngine = PitchEngine(delegate: self)
    private var onPitchReceived: ((Pitchy1.Note) -> Void)?

    init(onPitchReceived: ((Pitchy1.Note) -> Void)?) {
        self.onPitchReceived = onPitchReceived
    }

    func start() {
        pitchEngine.start()
    }

    func stop() {
        pitchEngine.stop()
    }
}

extension PitchDetector: PitchEngineDelegate {
    func pitchEngine(_ pitchEngine: Beethoven_iOS.PitchEngine, didReceivePitch pitch: Pitchy1.Pitch) {
        onPitchReceived?(pitch.note)
    }

    func pitchEngine(_ pitchEngine: Beethoven_iOS.PitchEngine, didReceiveError error: any Error) {
        print(error)
    }

    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: Beethoven_iOS.PitchEngine) {
        print("below level threshold")
    }
}

extension Pitchy1.Note.Letter {
    var keyNumber: Int {
        switch self {
        case .C: 0
        case .CSharp: 1
        case .D: 2
        case .DSharp: 3
        case .E: 4
        case .F: 5
        case .FSharp: 6
        case .G: 7
        case .GSharp: 8
        case .A: 9
        case .ASharp: 10
        case .B: 11
        }
    }
}
