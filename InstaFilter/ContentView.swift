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
    @State private var processesImage:UIImage?
    
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 1.0
    
    @State private var showPickerSheet = false
    @State private var currentFilter:CIFilter = CIFilter.sepiaTone()
    @State private var showingFilterSheet = false
    
    @State private var saveButtonDisabled = true
    @State private var radiusDisabled = false
    @State private var intensityDisabled = false
    
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
                        .onChange(of: filterIntensity){_ in
                            loadImage()
                        }
                }.padding(.vertical)
                    .disabled(intensityDisabled)
                
                HStack{
                    Text("Radius:")
                    Slider(value: $filterRadius)
                        .onChange(of: filterRadius){_ in
                            loadImage()
                        }
                }.padding(.vertical)
                    .disabled(radiusDisabled)
                
                HStack{
                    Button("Change Filter"){showingFilterSheet = true}
                    Spacer()
                    Button("Save Photo",action:save)
                        .disabled(saveButtonDisabled)
                }
                
            }
            .padding([.horizontal,.bottom])
            .navigationTitle(currentFilter.name)
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
        saveButtonDisabled = false
        applyProcessing()
    }
    
    func save(){
        guard let processesImage = processesImage else{return}
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success")
        }
        imageSaver.errorHandler = {
            print("oops \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processesImage)
    }
    
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey){
            intensityDisabled = false
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            radiusDisabled = false
            currentFilter.setValue(filterRadius * 20, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            currentFilter.setValue(filterIntensity, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else {return}
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processesImage = uiImage
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
