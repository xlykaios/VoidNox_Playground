import SwiftUI
import AVFoundation

//MARK: Frequency Buzzer Player
class SineWavePlayer: NSObject, ObservableObject {
    public var audioEngine: AVAudioEngine!
    private var audioSourceNode: AVAudioSourceNode!
 
    @Published var isPlaying: Bool
    @Published var frequency: Double
    @Published var sampleRate: Double
    @Published var volume : Float
 
    init(frequency: Double, isPlaying: Bool, sampleRate: Double, volume: Float) {
        self.frequency = frequency
        self.isPlaying = isPlaying
        self.sampleRate = sampleRate
        self.volume = volume
        super.init()
        setupAudioEngine()
    }
 
    private func setupAudioEngine() {
         audioEngine = AVAudioEngine()
        
        audioSourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            audioSourceNode.volume = volume
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sampleRate = self.sampleRate
            let frequency = self.frequency
 
            for frame in 0..<Int(frameCount) {
                let sampleTime = Double(frame) / sampleRate
                let value = sin(2.0 * .pi * frequency * sampleTime)
                let scaledValue = Int16(value * Double(Int16.max))
 
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Int16> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = scaledValue
                }
            }
            return noErr
        }
 
        let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100, channels: 1, interleaved: true)
        audioEngine.attach(audioSourceNode)
        audioEngine.connect(audioSourceNode, to: audioEngine.mainMixerNode, format: format)
 
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine failed to start: \(error)")
        }
    }
 
//    public func start() {
//        isPlaying = true
//    }
//
//    public func stop() {
//        isPlaying = false
//    }
}
//MARK: Geometrical Wavelenght Definition
struct Wave: Shape {
    // SwiftUI Animation of the Wave
    var animatableData: Double {
        get { phase }
        set { self.phase = newValue }
    }

    // --Height of the wave--
    var strength: Double

    // --Frequency of the wave--
    var frequency: Double

    // --Waves Offset--
    var phase: Double

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()

        // Value Calculation
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midWidth = width / 2
        let midHeight = height / 2
        let oneOverMidWidth = 1 / midWidth

        // Calculate the wavelenght basing on the frequency
        let wavelength = width / frequency

        // Starting point
        path.move(to: CGPoint(x: 0, y: midHeight))

        // Count horizontal points one by one
        for x in stride(from: 0, through: width, by: 1) {
            // Current position relative to the wavelength
            let relativeX = x / wavelength

            // How far we are from the horizontal center
            let distanceFromMidWidth = x - midWidth

            // Bring that into the range of -1 to 1
            let normalDistance = oneOverMidWidth * distanceFromMidWidth

            let parabola = -(normalDistance * normalDistance) + 1

            // calculate the sine of that position, adding our phase offset
            let sine = sin(relativeX + phase)

            // Multiply that sine by our strength to determine final offset, then move it down to the middle of our view
            let y = parabola * strength * sine + midHeight

            // add a line to here
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return Path(path.cgPath)
    }
}
//MARK: Byte to Integer Converter Function
func endStream (BitString : String) -> Int {
    let number = Int(BitString, radix: 2) ?? 0
    return number
}
//MARK: ContentView
struct ContentView: View {
    
    //MARK: Variables
    // A skip boolean used by the skip button
    @State var skip: Bool = false
    // A control/indexing variable to check which card has to be showed
    @State var selectedPage: Int = 0
    //Object representing the SineWave Audio player, with the basel
    @StateObject private var sineWavePlayer = SineWavePlayer(frequency: 300, isPlaying: false, sampleRate: 44000.0, volume: 0.0)
    
    //Variables regarding the visual wave, such as the phase, strenght and frequency
    @State private var phase = 0.0
    @State var counterStr = 0.0
    @State var counterFreq = 0.0
    
    //Variables regarding the logical aspect of the visualized data, such as the Bit String that represents the stack of values inserted by the user; indexQuote, indexOpacity and StringQuote are used for the selection of the quote from the string array defined in the PhrasesList array
    @State var BitString : String = ""
    @State var indexQuote : Int = 0
    @State var indexOpacity : Bool = false
    @State var StringQuote : String = ""
    @State var genButtonOpacity : Bool = true
    
    //Gradient used for the background
    static let gradientStart = Color(red: 31.0 / 255, green: 31.0 / 255, blue: 31.0 / 255)
    
    //MARK: Body
    var body: some View {
    ZStack{
       // Skip button that is over the TabView in order to keep a static button instead of making it slide with the cards
        Button(">Skip<"){
            skip.toggle()
            
        }
            .foregroundColor(.white)
            .font(.system(size: 30, design: .monospaced))
            .zIndex(2)
            .offset(x:400,y:-600)
            .opacity(skip ? 0:1)
    // Simplified test of a boarding screen without the usage of storyboards, to keep everything going with native SwiftUI
        TabView(selection: $selectedPage) {
            ForEach(0..<cardFlow.count){ index in
                CardView(card: cardFlow[index]).tag(index)
            }
        }
        .zIndex(skip ? -1:1)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .indexViewStyle(PageIndexViewStyle())
        ZStack {
            //Wave generator, will generate a set amount of waves, basing on the one provided in the For Each, with a set opacity and offset to display the visual effect
            ForEach(0..<25) { i in
                Wave(strength: counterStr, frequency: counterFreq, phase: self.phase)
                    .stroke(Color.white.opacity(Double(i) / 50), lineWidth: 4)
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
        VStack {
            ZStack {
                // Text field representing the string of continuos bits derived by user input
                    Text(BitString)
                        .offset(y:150)
                        .foregroundColor(.white)
                        .font(.system(size: 40, design: .monospaced))
                
                //MARK: Quote Stack - The Hstack containing the converted binary with a Quote from the PhrasesList
                    HStack{
                        //Text field containing the converted binary translated as an index for the Quotes Array
                        Text(String(indexQuote))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(.system(size: 60, design: .monospaced))
                            .opacity(indexOpacity ? 1:0)
                        //Text field containing the quote extracted by the Launch Button Function
                        Text(StringQuote)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, -1.0)
                            .frame(width: 700.0, height: 100.0)
                            .foregroundColor(.white)
                            .font(.system(size: 25, design: .monospaced))
                            .padding(.leading, 45)
                    }.offset(y:350)
                
                //TODO: MUTE BUTTON
                // Simplified version of a mute function, instead of stopping the track completely, it checks if the volume is zero, and if yes, it toggles to an higher volume
                Button{
                    if(sineWavePlayer.volume == 0){
                        sineWavePlayer.volume = 0.3
                        sineWavePlayer.isPlaying = true                    }else{
                        sineWavePlayer.volume = 0
                        sineWavePlayer.isPlaying = false
                    }
                } label: {
                    Image(systemName: sineWavePlayer.isPlaying ? "speaker.wave.3.fill" : "speaker.slash.fill")
                } .foregroundColor(.white)
                    .font(.system(size: 40))
                    .offset(x:445,y:-610)
                
                //MARK: ZERO BUTTON - Adds 0 to the stack
                Button("0") {
                    //Condition : if the size of the string is less than 8 it will continue, otherwise the function will stop adding bits
                        if(BitString.count<=7){
                        //The strenght of the wave will be increased by a number between 5 and 20, even if this will lead to an improper visualization of the wave, it's needed to constantly create new and random patterns
                        counterStr += Double(Int.random(in: 5...20))
                        // The 0 value will be added to the stack
                        BitString.append(String("0"))
                        // The sample rate of the sound will be increased of a fixed amount to generate a variety of sounds
                        sineWavePlayer.sampleRate -= 1000
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.white)
                .font(.system(size: 90, design: .monospaced))
                    .shadow(radius: 10)
                    .offset(x:-70,y:550)
                
                //MARK: ONE BUTTON
                Button("1") {
                   //Condition : if the size of the string is less than 8 it will continue, otherwise the function will stop adding bits
                    if(BitString.count<=7){
                        //The frequency of the wave will be increased by a number between 5 and 20, even if this will lead to an improper visualization of the wave, it's needed to constantly create new and random patterns
                        counterFreq += Double(Int.random(in: 5...20))
                        // The 1 value will be added to the stack
                        BitString.append(String("1"))
                        // The frequency of the sound will be increased of a fixed amount to generate a variety of sounds
                        sineWavePlayer.frequency += 25
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.white)
                .font(.system(size: 90, design: .monospaced))
                .offset(x:70,y:550)
                .shadow(color: .white, radius: 1)
                
                //MARK: CONFIRM BUTTON - Launch button to convert the binary into an integer and allows the selection of the quote from the PhrasesList array
                Button{
                    //The binary string will be converted to an the indexQuote integer
                    indexQuote = endStream(BitString: BitString)
                    //The Picked quote will be selected from the quotes array, at the position defined by the integer
                   StringQuote = Quotes[indexQuote]
                    //The opacity of the index will be toggled to only show it when the quote is present
                    indexOpacity.toggle()
                    genButtonOpacity.toggle()
                }label: {
                    Image(systemName: "waveform.path")
                }.offset(y:450)
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                    .opacity(((BitString.count == 8 && genButtonOpacity == true) ? 1:0))
                    .animation(.easeInOut, value: 0.8)
                    .shadow(color: .white, radius: 0.2)
                    .font(.system(size: 33))
                
                //MARK: FLUSH BUTTON - Multi-Purpose Button that resets the actual status of the model
                Button("X") {
                    counterStr = 0;
                    counterFreq = 0;
                    BitString = ""
                    indexQuote = 0
                    StringQuote = ""
                    indexOpacity = false
                    sineWavePlayer.frequency = 0
                    sineWavePlayer.sampleRate = 100
                    genButtonOpacity = true
                }.buttonStyle(UIButton())
                .offset(x:435, y:610)
                .shadow(radius: 10)
                .font(.system(size: 20))
                }
            }
        }
    }
}
