//
//  ContentView.swift
//  Shoseki_Kansu
//
//  Created by hw19a134 on 2021/10/15.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType:UIImagePickerController.SourceType   = .camera
    @State private var image: UIImage?
    
    var body: some View {
        NavigationView{
            VStack{
                Button("写真モード選択"){
                    self.showSheet = true
                }.padding()
                .actionSheet(isPresented: $showSheet){
                    ActionSheet(title: Text("選択"), message: Text("選択"), buttons: [
                        .default(Text("写真フォルダ")){
                            self.showImagePicker = true
                            self.sourceType = .photoLibrary
                            
                        },
                        .default(Text("カメラ起動")){
                            self.showImagePicker = true
                            self.sourceType = .camera
                            
                        },
                        .cancel()
                    ])
                        
                }
            }
            .navigationBarTitle("camera demo")
        }.sheet(isPresented: $showImagePicker){
            ImagePicker(image: $image,sourceType: self.sourceType)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
