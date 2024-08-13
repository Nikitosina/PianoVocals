//
//  KeyView.swift
//  PianoVocals
//
//  Created by Nikita Ratashnyuk on 13.08.2024.
//

import SwiftUI

struct KeyView: View {
    @ObservedObject var pianoVM: PianoViewModel
    @GestureState private var isTapped = false
    var octave: Int
    var i: Int
    var keyInfo: KeyInfo
    var width: CGFloat

    var body: some View {
        let tap = DragGesture(minimumDistance: 0)
            .updating($isTapped) { (_, isTapped, _) in
                isTapped = true
            }

        return ZStack(alignment: .bottom) {
            Rectangle()
                .frame(width: width)
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 0
                    )
                )
                .foregroundStyle(keyInfo.color.value(isPressed: keyInfo.isPressed))
                .overlay(content: {
                    Color.yellow.opacity(pianoVM.highlightedNote?.keyNumber == keyInfo.n ? 0.5 : 0).cornerRadius(8)
                })
            if i == 0, keyInfo.color == .white {
                Text("C\(octave - 1)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 4)
            }
        }
        .if(pianoVM.scrollDisabled) { $0.gesture(tap) }
        .onChange(of: isTapped) { _, newValue in
            newValue ? pianoVM.playKey(at: keyInfo.n) : pianoVM.stopKey(at: keyInfo.n)
        }
    }
}
