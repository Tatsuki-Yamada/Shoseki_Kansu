import SwiftUI
import Alamofire
import Kanna


class ScrapeObject : ObservableObject
{
    // 本のタイトルがStringで入る
    var bookTitle = ""
    
    // 見出しと巻数を格納するリスト
    var headers: [String] = []
    var volumes: [String] = []
    
    
    init(title: String)
    {
        print("\nScrapeObject_init...\n")
        
        self.bookTitle = title
        
        // 正規表現でタイトルの後ろについた巻数の数字を消す
        self.bookTitle = self.bookTitle.replacingOccurrences(
            of: "[0-9]+$",
            with: "",
            options: .regularExpression
        )
        
        OpenSearch()
    }
    
    
    // タイトルをBingで検索し、Wikipediaのサイトを見つけるように投げる巻数。
    func OpenSearch()
    {
        print("\nOpenWiki...\n")
        
        let encodeTitleString = self.bookTitle.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let urlString = "https://www.bing.com/search?q=\(encodeTitleString!)+Wikipedia&mkt=ja-JP"
        //let urlString = "https://www.google.com/search?q=\(encodeTitleString!)+Wikipedia&hl=ja"
        
        // urlからHTMLに変換してGetWikiLinkに投げる。
        AF.request(urlString).responseString { response in
            switch response.result {
                case let .success(value):
                    self.GetWikiLink(html: value)
                
                case let .failure(error):
                    print(error)
            }
        }
    }
    
    
    // もらったHTMLからja.wikipediaのリンクを探して更に投げる巻数。
    func GetWikiLink(html: String)
    {
        print("\nGetWikiLink...\n")
        
        if let doc = try? HTML(html: html, encoding: .utf8)
        {
            for d in doc.css("a[href]")
            {
                let link = d["href"]!
                if (link.contains("ja.wikipedia"))
                {
                    // urlからHTMLに変換してParseHTMLに投げる。
                    AF.request(link).responseString { response in
                        switch response.result {
                            case let .success(value):
                                self.ParseHTML(html: value)
                            
                            case let .failure(error):
                                print(error)
                        }
                    }
                    break
                }
            }
        }
    }
    
    
    // HTMLをもらってWikipediaの中身をスクレイピングする
    func ParseHTML(html: String)
    {
        print("\nParseHTML...\n")
        
        if let doc = try? HTML(html: html, encoding: .utf8)
        {
            print(doc.xpath("//h1[@id='firstHeading']").first?.text)
            // Wikipediaの書籍情報部分を取得する
            let infoBox = doc.xpath("//table[@class='infobox bordered']//tr")
            
            // 書籍情報を走査する
            for i in infoBox
            {
                let str = i.text!
                
                // 改行文字を削除する
                let text = str.replacingOccurrences(of: "\n", with: "")
                
                // [小説][漫画]など大項目の部分であるかを調べる
                var headerFlag = false
                for _ in i.xpath("//th[@style='background:#ccf; text-align:center; white-space:nowrap']")
                {
                    headerFlag = true
                }
                
                // 見出しなら、それだけを取り出すリストに追加する
                if headerFlag
                {
                    self.headers.append(text)
                }
                
                // 先頭2文字が"巻数"なら、そのあとに続く文字列をリストに追加する
                if text.prefix(2) == "巻数"
                {
                    let startIndex = text.index(text.startIndex, offsetBy: 2)
                    let endIndex = text.index(text.endIndex, offsetBy: -1)
                    let cutStr: String = String(text[startIndex...endIndex])
                    self.volumes.append(cutStr)
                }
            }
            
            print(self.headers)
            print(self.volumes)
        }
    }
}
