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
    @State var media: [String] = []
    @State var volume: [String] = []
    @State var previousCode: String = ""
    @State var showInfoSemaphoe: Bool = true
    
    
    // ISBNコードであるか判定する関数
    func isMatchISBN(code: String) -> Bool
    {
        // 文字列の長さが10文字か13文字のときのみ追加で操作する
        if code.count == 10
        {
            var sum = 0
            var mult = 10
            
            // 各桁を足していく
            // summary: https://mathsuke.jp/isbn-10/
            // summary: http://datablog.trc.co.jp/2007/01/30133853.html
            for c in code
            {
                let c: String = String(c)
                
                if code == "X"
                {
                    sum += 10
                }
                else
                {
                    sum += Int(c)! * mult
                }
                
                mult -= 1
            }
            
            if sum % 11 == 0
            {
                print(sum)
                return true
                
            }
            else
            {
                return false
            }
        }
        else if code.count == 13
        {
            /*
            let pattern = "978[0-9]{10}"
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return false };
            let checkingResults = regex.matches(in: code, range: NSRange(location: 0, length: code.count))
            return checkingResults.count > 0
             */
            var sum: Int = 0
            
            var i: Int = 0
            for c in code
            {
                i += 1
                
                let c: String = String(c)
                
                // 13桁目のとき、チェックデジットと同じか照合する
                if i == 13
                {
                    sum %= 100
                    sum %= 10
                    
                    print("check 1")
                    
                    if Int(c)! == (10 - sum)
                    {
                        print(c)
                        print("check true")
                        return true
                    }
                    else
                    {
                        print("check false")
                        return false
                    }
                }
                
                // 奇数桁の処理
                if i % 2 == 1
                {
                    sum += Int(c)!
                }
                // 偶数桁の処理
                else
                {
                    sum += Int(c)! * 3
                }
                
            }
        }

        return false
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
                            
                            // 情報の更新を行っている段階で画面の描画が入ると高確率でOutOfRangeが発生するため、情報の更新が終わるまで画面の描画を止める
                            showInfoSemaphoe = false
                            
                            // Wikipediaのスクレイピングをするオブジェクトの作成
                            let scrapeObject = ScrapeObject(title: title)
                            scrapeObject.OpenSearch({media, volume in
                                self.media = []
                                for m in media
                                {
                                    self.media.append(m)
                                }
                                
                                self.volume = []
                                for v in volume
                                {
                                    self.volume.append(v)
                                }
                                
                                // 情報の更新が終わったので画面の描画を再開する
                                showInfoSemaphoe = true
                            })
                            
                        })
                    }
                }
            )
            Text("バーコードを赤い枠の中に写してください").foregroundColor(.red)
            List{
                Section{
                    Text(title).fontWeight(.heavy)
                } header:{
                    Text("タイトル").fontWeight(.black).foregroundColor(.blue)
                }
                
                // 情報の更新を行っている際は画面に表示しない
                // TODO. wikipediaがなかったときのvolume mediaのout of range修正
                if showInfoSemaphoe
                {
                    ForEach(0..<media.count, id:\.self){ i in
                        Section{
                            if i < volume.count
                            {
                                Text(volume[i]).fontWeight(.heavy)
                            }
                            else
                            {
                                Text("").fontWeight(.heavy)
                            }
                        } header:{
                            if i < media.count
                            {
                                Text(media[i]).fontWeight(.black)
                            }
                        }
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
