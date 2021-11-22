//
//  ContentView.swift
//  model
//
//  Created by hw19a050 on 2021/11/08.
//

import SwiftUI

struct ContentView: View {
    @State var isPresentingScanner = false
    @State var scannedCode: String = "Scan a QR code to get started."
    @State var title: String = "title"
    
    var scannerSheet : some View {
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
                    })
                }
            }
        )
    }
    var body: some View {
        VStack(spacing: 10){
            Text(scannedCode)
            Text(title)
            
            Button("Scan QR Code"){
                self.isPresentingScanner = true
            }
            .sheet(isPresented: $isPresentingScanner){
                self.scannerSheet
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
