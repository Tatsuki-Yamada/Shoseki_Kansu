import SwiftUI


struct ISBN_View : View
{
    @ObservedObject var Books = ISBNObject(isbn: "")
    
    var body: some View
    {
        Text("ISBN_View")
    }
}


class ISBNObject : ObservableObject{
    var isbn = ""
    
    init(isbn: String)
    {
        //let sukasuka : String = "9784041040393"
        //let kimetsu : String = "9784088807232"
        //let kimetsu23 : String = "9784088824956"
        //let levelE : String = "9784088720715"
        
        self.isbn = isbn
    }
    
    
    // Google Books APIsからタイトルを取得する
    func GetTitle(_ after:@escaping (String) -> ())
    {
        var title = ""
        // isbn="isbnコード"でISBNに一致する本の検索
        //let url = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(self.isbn)&Country=JP"
        let url = "https://api.openbd.jp/v1/get?isbn=\(self.isbn)"
        
        let session = URLSession(configuration: .default)
        
        // URLリクエストのタスクを作成する
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            if err != nil
            {
                print((err?.localizedDescription)!)
                return
            }
            
            // もらったJSONを扱える形に変換する
            let json = try! JSON(data: data!)
            title = json[0]["onix"]["DescriptiveDetail"]["TitleDetail"]["TitleElement"]["TitleText"]["content"].stringValue
            print(title)
            
            DispatchQueue.main.async {
                after(title)
            }
        }.resume()
        
    }
}

