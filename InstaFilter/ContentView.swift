//
//  ContentView.swift
//  InstaFilter
//
//  Created by Bahadır Ersin on 5.03.2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    
    @State private var image:Image?
    @State private var inputImage:UIImage?
    @State private var filterIntensity = 0.5
    @State private var showPickerSheet = false
    @State private var currentFilter:CIFilter = CIFilter.sepiaTone()
    @State private var showingFilterSheet = false
    
    let context = CIContext()
    
    var body: some View {
        NavigationView{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a photo")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }.onTapGesture {
                    showPickerSheet = true
                }
                
                HStack{
                    Text("Intensity:")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity){_ in applyProcessing()}
                }.padding(.vertical)
                
                HStack{
                    Button("Change Filter"){showingFilterSheet = true}
                    Spacer()
                    Button("Save Photo",action:save)
                }
                
            }
            .padding([.horizontal,.bottom])
            .navigationTitle("InstaFilter")
            .onChange(of: inputImage){ _ in
                loadImage()
            }
            .sheet(isPresented: $showPickerSheet){
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select the filter", isPresented: $showingFilterSheet){
                Button("Crystallize"){currentFilter = CIFilter.crystallize()}
                Button("Edges"){currentFilter = CIFilter.edges()}
                Button("Gaussian Blur"){currentFilter = CIFilter.gaussianBlur()}
                Button("Pixellate"){currentFilter = CIFilter.pixellate()}
                Button("Unsharp Mask"){currentFilter = CIFilter.unsharpMask()}
                Button("Vignette"){currentFilter = CIFilter.vignette()}
                Button("Sepia Tone"){currentFilter = CIFilter.sepiaTone()}
                Button("Cancel",role:.cancel){}
            }
        }
    }
    
    func loadImage(){
        guard let inputImage = inputImage else {return}
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save(){
        
    }
    
    func applyProcessing(){
        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        
        guard let outputImage = currentFilter.outputImage else {return}
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
        }
    }
    
    func setFilter(_ filter:CIFilter){
        currentFilter = filter
        loadImage()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
