//
//  Card.swift
//  VoidNox
//
//  Created by Antonio Giordano on 18/04/23.
//

import Foundation

struct Card: Identifiable{
    
// Here we're defining the structure of the Card that will be shown in the Boarding Screens section
    var id = UUID()
    var text1: String
    var text2: String
    var text3: String?
    var WavFrequency: Double
    var WavStrenght: Double
}
// And this is the data that will be shown, with specific Frequencies and strenght values for the wavelenght
var cardFlow : [Card] = [
    Card(text1: "There once was a line...", text2: "That wasn't really 'just' a line.", WavFrequency: 0.0, WavStrenght: 0.0),
    Card(text1: "Day by day...", text2: "Choice after choice...", WavFrequency: 10.0, WavStrenght: 10.0),
    Card(text1: "It became something new...", text2: "It became something beautiful...", WavFrequency: 60.0, WavStrenght: 140.0),
    Card(text1: "Everybody starts as a line in this world of data", text2: "0 Charges you with Power \n\n1 Enlightens you with Freedom \n\n\n\nIt's your turn to shape your life",text3: "# It's suggested to lower the volume, as the wave comes with an audio representation #" , WavFrequency: 5.0, WavStrenght: 5.0)
]
