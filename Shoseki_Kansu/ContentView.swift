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
    @State var scannedCode: String = "Scan a QR code to get started."
    @State var title: String = ""
    @State var media: String = ""
    @State var volume: String = ""
    @State var previousCode: String = ""
    
    
    // ISBNコードであるか判定する関数
    func isMatchISBN(code: String) -> Bool
    {
        let pattern = "978[0-9]{10}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false };
        let checkingResults = regex.matches(in: code, range: NSRange(location: 0, length: code.count))
        return checkingResults.count > 0
    }
    
    
    var body: some View {
        VStack(spacing: 10){
            // CodeScannerViewを呼び出して処理を行う
            CodeScannerView(
                codeTypes: [.ean13],
                completion:{ result in
                    if case let .success(code) = result {
                        // 成功したときの処理。code変数に読み取ったコードが入っている
                        self.scannedCode = code
                        
                        // ISBNでは無いコードか、前回と同じコードを読み取ったら弾く
                        if (!isMatchISBN(code: code) || code == previousCode)
                        {
                            return
                        }
                        
                        self.previousCode = code
                        
                        // APIに投げる処理を行うオブジェクトの作成
                        let isbnObject = ISBNObject(isbn:code)
                        isbnObject.GetTitle({ title in
                            self.title = title
                            
                            // Wikipediaのスクレイピングをするオブジェクトの作成
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
