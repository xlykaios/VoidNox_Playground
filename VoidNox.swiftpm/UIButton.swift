//
//  UIButton.swift
//  VoidNox
//
//  Created by Antonio Giordano on 17/04/23.
//

import SwiftUI

struct UIButton: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 20.0)
            .padding(.horizontal, 25)
            .background(Color(red: 0.3, green: 0.3, blue: 0.3))
            .foregroundColor(.white)
            .clipShape(Ellipse())
            .scaleEffect(configuration.isPressed ? 0.8 : 1.2)
            .animation(.easeIn(duration: 0.2), value: configuration.isPressed)
        
    }
}

struct UIButt: View {
    var body: some View {
        Button("POP"){
          
        }
        .padding()
                .buttonStyle(UIButton())
                
    }
}

struct UIButt_Previews: PreviewProvider {
    static var previews: some View {
        UIButt()
    }
}


