//
//  ContentView.swift
//  SafeIt
//
//  Created by Christina Pouli on 02/05/2021.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedChar: Char?
    @State private var charConfirmedForPlacement: Char?
    
    
    private var chars: [Char] = {
        //Use filemanager to dynamically get our chars filenames
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableChars: [Char] = []
        for filename in files where filename.hasSuffix("usdz"){
            let charName = filename.replacingOccurrences(of: ".usdz", with: "")
            let char = Char(charName: charName)
            availableChars.append(char)
        }
        
        return availableChars
    }()
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(charConfirmedForPlacement: self.$charConfirmedForPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedChar: self.$selectedChar, charConfirmedForPlacement: self.$charConfirmedForPlacement)
            }else{
                SafeItView(isPlacementEnabled: self.$isPlacementEnabled, selectedChar: self.$selectedChar, chars: self.chars)
            }
            
            
                
            }
        }
    }


struct ARViewContainer: UIViewRepresentable {
    @Binding var charConfirmedForPlacement: Char?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        
       
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        func add(_ sender: Any) {
            guard let currentFrame = arView.session.currentFrame else  { return }

            var translation = matrix_identity_float4x4
            translation.columns.3.z = -2

            let transform = currentFrame.camera.transform
            let anchorTransform = matrix_multiply(transform, translation)

            let anchor = ARAnchor(transform: anchorTransform)
            arView.session.add(anchor: anchor)


        }
        
        return arView

        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        if let char = self.charConfirmedForPlacement {
          
            if let charEntity = char.charEntity {
                
                print("DEBUG: adding char to scene - \(char.charName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(charEntity)
                
                
                
            
            
                uiView.scene.addAnchor(anchorEntity
                    .clone(recursive: true))
                
                
            } else {
                
                print("DEBUG: anuable to load charEntity to scene - \(char.charName)")
            }
            
            DispatchQueue.main.async {
                self.charConfirmedForPlacement = nil
            }
            
            
        }
        
        
    }
    
}

//Create our SafeItChars view

struct SafeItView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedChar: Char?
    
    var chars: [Char]
    
    var body: some View{
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30){
                ForEach(0..<self.chars.count){ index in
                    Button(action: {print("DEBUG: selected char with name: \(self.chars[index].charName)")
                        
                        self.selectedChar = self.chars[index]
                        
                        self.isPlacementEnabled = true
                        
                    })
                    {
                        Image(uiImage: self.chars[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                
                }
                
            }
        }
        .padding(20)
        .background(Color.red.opacity(10.5))
        
    }
}

//Create our Placement UI

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedChar: Char?
    @Binding var charConfirmedForPlacement: Char?
    
    var body: some View{
        HStack{
            Button(action: {print("DEBUG: Confirm char placement")
                
                self.charConfirmedForPlacement = self.selectedChar
                
                self.resetPlacementParameters()
            }){
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.red
                                    .opacity(10.5))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            
            Button(action: {
                print("DEBUG: Cancel char placement")
                
                self.resetPlacementParameters()
            }){
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.red
                                    .opacity(10.5))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
        
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedChar = nil
    }
    
    
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
