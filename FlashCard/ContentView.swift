import SwiftUI

struct Word: Identifiable, Codable {
    let id = UUID()
    let english: String
    let chinese: String
}

class WordStore: ObservableObject {
    @Published var words: [Word] = [] {
        didSet { save() }
    }
    
    init() {
        load()
    }
    
    func addWord(english: String, chinese: String) {
        let word = Word(english: english, chinese: chinese)
        words.append(word)
    }
    
    func randomWord() -> Word? {
        words.randomElement()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(data, forKey: "words")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: "words"),
           let saved = try? JSONDecoder().decode([Word].self, from: data) {
            words = saved
        }
    }
}

struct ContentView: View {
    @StateObject private var store = WordStore()
    @State private var english = ""
    @State private var chinese = ""
    @State private var showTranslation = false
    @State private var quizWord: Word?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Form {
                    Section(header: Text("新增單字")) {
                        TextField("英文單字", text: $english)
                        Button("查詢並加入") {
                            translateAndAdd()
                        }.disabled(english.isEmpty)
                        if !chinese.isEmpty {
                            Text("翻譯：\(chinese)")
                        }
                    }
                }
                Divider()
                VStack(spacing: 12) {
                    Button("隨機測驗單字") {
                        quizWord = store.randomWord()
                        showTranslation = false
                    }.disabled(store.words.isEmpty)
                    if let word = quizWord {
                        Text(word.english)
                            .font(.largeTitle)
                            .padding()
                        if showTranslation {
                            Text(word.chinese)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        } else {
                            Button("顯示翻譯") {
                                showTranslation = true
                            }
                        }
                    }
                }
                Divider()
                List(store.words) { word in
                    VStack(alignment: .leading) {
                        Text(word.english).bold()
                        Text(word.chinese).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("FlashCard 單字卡")
        }
    }
    
    func translateAndAdd() {
        // 這裡用簡單範例，實際可串接翻譯 API
        let dict: [String: String] = [
            "apple": "蘋果",
            "book": "書",
            "cat": "貓",
            "dog": "狗",
            "run": "跑步",
            "banana": "香蕉",
            "egg": "蛋"
        ]
        let result = dict[english.lowercased()] ?? "(請自行輸入翻譯)"
        chinese = result
        store.addWord(english: english, chinese: result)
        english = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
