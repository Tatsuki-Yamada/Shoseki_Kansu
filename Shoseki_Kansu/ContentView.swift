//
//  ContentView.swift
//  model
//
//  Created by hw19a050 on 2021/11/08.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    @State var isPresentingScanner = true
    @State var scannedCode: String = "Scan a QR code to get started."
    @State var title: String = "title"
    @State var volume: String = "volume"
    
    
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
                            scrapeObject.OpenSearch({volume in
                                self.volume = ""
                                for v in volume
                                {
                                    self.volume += v
                                }
                                //self.volume = ""
                            })
                        })
                        
                        
                        
                    }
                }
            )
            Text(scannedCode)
            Text(title)
            Text(volume)
            Text(" ")
            Text(" ")
            Text(" ")
            Text(" ")
            Text(" ")
            Text(" ")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
