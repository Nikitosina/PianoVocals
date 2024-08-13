//
//  ContentView.swift
//  PianoVocals
//
//  Created by Nikita Ratashnyuk on 12.08.2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var pianoVM = PianoViewModel()
    @State var whiteKeyWidth: CGFloat = 60
    // needs iOS 18
    // @State private var position = ScrollPosition(edge: .leading)
    @State var contentOffset: CGFloat = 1400
    @State var maxOffset: CGFloat = 0

    var blackKeyWidth: CGFloat {
        0.6 * whiteKeyWidth
    }

    var body: some View {
        VStack {
            Spacer()

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 1) {
                        ForEach(0..<10) { n in
                            octave(n: n)
                                .id(n)
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.onChange(of: whiteKeyWidth, initial: true) { _, _ in
                                maxOffset = proxy.size.width
                            }
                        }
                    )
                }
                .scrollDisabled(pianoVM.scrollDisabled)
//                .scrollPosition($position)
                .simultaneousGesture(
                    MagnifyGesture()
                        .onChanged { value in
                            if !pianoVM.scrollDisabled {
                                whiteKeyWidth = (whiteKeyWidth + (value.magnification - 1)).clamped(to: 40...80)
                            }
                        }
                )
                .onAppear {
                    proxy.scrollTo(5, anchor: .trailing)
                }
//                .onChange(of: contentOffset, initial: true) { _, newOffset in
//                    withAnimation {
//                        position.scrollTo(x: newOffset)
//                    }
//                }
            }

            Spacer()

            bottomBar
        }
        .background(Color.gray)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                pianoVM.restartAudioEngine()
            }
        }
    }

    @ViewBuilder
    func octave(n: Int) -> some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 1) {
                ForEach(0..<7) { i in
                    KeyView(pianoVM: pianoVM, octave: n, i: i, keyInfo: pianoVM.allKeys[pianoVM.whiteKeyIndex(octave: n, i: i)], width: whiteKeyWidth)
                }
                .frame(maxHeight: 300)
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
                .frame(maxHeight: 150)
            }
            .offset(x: whiteKeyWidth * 0.7)
        }
    }

    var bottomBar: some View {
        HStack {
//            Button(action: {
//                contentOffset = max(0, contentOffset - 100)
//            }) {
//                Image(systemName: "chevron.left")
//                    .padding()
//                    .background(Circle().foregroundStyle(.white))
//            }
            Spacer()
            Button(action: { pianoVM.scrollDisabled.toggle() }) {
                Text("Scroll mode")
                    .foregroundStyle(pianoVM.scrollDisabled ? .white : .blue)
                    .padding()
                    .background(pianoVM.scrollDisabled ? Color.clear : Color.white)
                    .cornerRadius(12)
            }
            Button(action: { pianoVM.pitchDetectionMode.toggle() }) {
                Image(systemName: "mic")
                    .foregroundStyle(pianoVM.pitchDetectionMode ? .blue : .white)
                    .padding()
                    .background(Circle().foregroundStyle(pianoVM.pitchDetectionMode ? .white : .clear))
            }
            if pianoVM.pitchDetectionMode {
                Text(pianoVM.highlightedNote?.letter ?? "None")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .opacity(pianoVM.highlightedNote == nil ? 0 : 1)
                    .frame(width: 60, height: 30)
                    .padding(.horizontal)
            }
            Spacer()
//            Button(action: {
//                contentOffset = min(maxOffset, contentOffset + 100)
//            }) {
//                Image(systemName: "chevron.right")
//                    .padding()
//                    .background(Circle().foregroundStyle(.white))
//            }
        }
        .padding()
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

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
