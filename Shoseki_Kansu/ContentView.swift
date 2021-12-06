//
//  ContentView.swift
//  model
//
//  Created by hw19a050 on 2021/11/08.
//

import SwiftUI
import Alamofire
import Foundation

struct ContentView: View {
    @State var isPresentingScanner = true
    @State var scannedCode: String = "Scan a QR code to get started."
    @State var title: String = ""
    @State var media: String = ""
    @State var volume: String = ""
    
    
    var body: some View {
        VStack(spacing: 10){
            CodeScannerView(
                codeTypes: [.ean13],
                completion:{ result in
                    if case let .success(code) = result {
                        // 成功したときの処理。code変数に読み取ったコードが入っている
                        self.scannedCode = code
                        self.isPresentingScanner = false
                        
                        let isbnObject = ISBNObject(isbn:code)
                        isbnObject.GetTitle({ title in
                            self.title = title
                            
                            let scrapeObject = ScrapeObject(title: title)
                            scrapeObject.OpenSearch({media, volume in
                                self.media = ""
                                for m in media
                                {
                                    self.media +=  "\(m),"
                                }
                                
                                self.volume = ""
                                for v in volume
                                {
                                    self.volume += "\(v),"
                                }
                            })
                        }) 
                    }
                }
            )
            let arr:[String] = media.components(separatedBy: ",")
            List{
                Section{
                    Text(title).fontWeight(.heavy)
                } header:{
                    Text("タイトル").fontWeight(.black)
                }
                ForEach(arr, id:\.self){ a in
                    Section{
                        Text(volume).fontWeight(.heavy)
                    } header:{
                        Text(a).fontWeight(.black)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
