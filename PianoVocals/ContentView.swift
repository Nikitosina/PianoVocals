//
//  ContentView.swift
//  PianoVocals
//
//  Created by Nikita Ratashnyuk on 12.08.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pianoVM = PianoViewModel()
    @State var whiteKeyWidth: CGFloat = 55
    @State private var position = ScrollPosition(edge: .leading)
    @State var contentOffset: CGFloat = 1400
    @State var maxOffset: CGFloat = 0

    var blackKeyWidth: CGFloat {
        0.6 * whiteKeyWidth
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            HStack {
                Text("White key width: \(Int(whiteKeyWidth))")
                    .foregroundStyle(.white)
                Slider(value: $whiteKeyWidth, in: 40...70)
            }
            .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(0..<10) { n in
                        octave(n: n)
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.onChange(of: whiteKeyWidth, initial: true) { _, _ in  print(proxy.size.width)
                            maxOffset = proxy.size.width
                        }
                    }
                )
            }
            .scrollDisabled(pianoVM.scrollDisabled)
            .scrollPosition($position)
//                .content.offset(x: contentOffset)
            .onChange(of: contentOffset, initial: true) { _, newOffset in
                withAnimation {
                    position.scrollTo(x: newOffset)
                }
            }

            Spacer()

            bottomBar
        }
        .background(Color.gray)
//        .onAppear {
//            contentOffset = 1400
//        }
    }

    @ViewBuilder
    func octave(n: Int) -> some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 1) {
                ForEach(0..<7) { i in
                    KeyView(pianoVM: pianoVM, octave: n, i: i, keyInfo: pianoVM.allKeys[pianoVM.whiteKeyIndex(octave: n, i: i)], width: whiteKeyWidth)
                }
                .frame(maxHeight: 250)
            }
            HStack(spacing: blackKeyWidth * 0.72) {
                ForEach(0..<5) { i in
                    if i == 2 {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(width: blackKeyWidth)
                    }
                    KeyView(pianoVM: pianoVM, octave: n, i: i, keyInfo: pianoVM.allKeys[pianoVM.blackKeyIndex(octave: n, i: i)], width: blackKeyWidth)
                }
                .frame(maxHeight: 125)
            }
            .offset(x: whiteKeyWidth * 0.7)
//            .background(.cyan.opacity(0.5))
        }
    }

    var bottomBar: some View {
        HStack {
            Button(action: {
                contentOffset = max(0, contentOffset - 100)
            }) {
                Image(systemName: "chevron.left")
                    .padding()
                    .background(Circle().foregroundStyle(.white))
            }
            Spacer()
            Button(action: { pianoVM.scrollDisabled.toggle() }) {
                Text("Scroll mode")
                    .foregroundStyle(pianoVM.scrollDisabled ? .white : .blue)
                    .padding()
                    .background(pianoVM.scrollDisabled ? Color.clear : Color.white)
                    .cornerRadius(12)
            }
            Spacer()
            Button(action: {
                contentOffset = min(maxOffset, contentOffset + 100)
            }) {
                Image(systemName: "chevron.right")
                    .padding()
                    .background(Circle().foregroundStyle(.white))
            }
        }
        .padding()
    }
}

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
            if i == 0 && keyInfo.color == .white {
                Text("C\(octave - 2)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)
            }
        }
        .if(pianoVM.scrollDisabled) { $0.gesture(tap) }
        .onChange(of: isTapped) { _, newValue in
            newValue ? pianoVM.playKey(at: keyInfo.n) : pianoVM.stopKey(at: keyInfo.n)
        }
    }
}

#Preview {
    ContentView()
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
