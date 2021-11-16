import SwiftUI


struct ISBN_View : View
{
    @ObservedObject var Books = ISBNObject(isbn: "9784041040393")
    
    var body: some View
    {
        Text("ISBN_View")
    }
}


class ISBNObject : ObservableObject{
    var isbn = ""
    
    init(isbn: String)
    {
        self.isbn = isbn
        
        //let sukasuka : String = "9784041040393"
        //let kimetsu : String = "9784088807232"
        //let kimetsu23 : String = "9784088824956"
    }
    
    
    // Google Books APIsからタイトルを取得する
    func GetTitle(_ after:@escaping (String) -> ())
    {
        var title = ""
        // q=タイトル名で通常の検索
        // q=isbn:isbnコードでISBNに一致する本の検索
        let url = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(self.isbn)&Country=JP"
        
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
            let items = json["items"].array!
            
            // JSONのデータを走査し、タイトルを取得する
            for i in items
            {
                title = i["volumeInfo"]["title"].stringValue
                print(title)
                
                DispatchQueue.main.async {
                    let so = ScrapeObject(title: title)
                    after(title)
                }
            }
        }.resume()
        
    }
}

