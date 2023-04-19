//
//  CardView.swift
//  VoidNox
//
//  Created by Antonio Giordano on 18/04/23.
//

import SwiftUI

struct CardView: View {
    @State private var phase = 0.0
    var card: Card
    var body: some View {
        //Creation of a simple ZStack in which we put everything necessary for the card, in order: the line, the custom wavelenght path and the second line
        ZStack{
        
            Text(card.text1)
                .foregroundColor(.white)
                .font(.system(size: 30, design: .monospaced))
                .zIndex(2)
                .offset(y:-300)
            
            Text(card.text2)
                .foregroundColor(.white)
                .font(.system(size: 30, design: .monospaced))
                .multilineTextAlignment(.center)
                .zIndex(2)
                .offset(y:300)
            
            Text(card.text3 ?? "")
                .foregroundColor(.white)
                .font(.system(size: 15, design: .monospaced))
                .multilineTextAlignment(.center)
                .zIndex(2)
                .offset(y:500)
            
            ZStack {
                //Wave generator, will generate a set amount of waves, basing on the one provided in the For Each, with a set opacity and offset to display the visual effect
                ForEach(0..<2) { i in
                    Wave(strength: card.WavStrenght, frequency: card.WavFrequency, phase: self.phase)
                        .stroke(Color.white.opacity(Double(i) / 2), lineWidth: 3)
                        .offset(y: -(CGFloat(i) * 10))
                }
            }
            .background(LinearGradient(gradient: Gradient(colors: [.black, ContentView.gradientStart]), startPoint: .top, endPoint: .bottom))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    self.phase = .pi * 2
                }
            }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: cardFlow[3])
    }
}
