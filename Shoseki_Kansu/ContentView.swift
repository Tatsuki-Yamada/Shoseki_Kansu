//
//  ContentView.swift
//  Shoseki_Kansu
//
//  Created by hw19a134 on 2021/10/15.
//

import SwiftUI

struct ContentView: View {
    @State private var sourceType:UIImagePickerController.SourceType   = .camera
    @State private var image: UIImage?
    
    var body: some View {
        ImagePicker(image: $image,sourceType: self.sourceType)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
