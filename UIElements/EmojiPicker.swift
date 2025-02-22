import SwiftUI

struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    @Binding var isPresented: Bool
    
    @ObservedObject var settings: Settings
    
    @State private var currentPage = 0
    
    // ✅ Emojis in Seiten unterteilt
    private let emojiPages: [[String]] = [
        // 😃 Emotionen & Gesichter
        ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇", "😍", "😜", "😎", "🤩", "🥳", "😢", "😭", "😡", "😱"],
        
        // 🐶 Tiere
        ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🦆", "🦉", "🦄"],
        
        // 🍏 Essen & Trinken
        ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍒", "🥑", "🥕", "🌽", "🍞", "🥐", "🧀", "🥩", "🍕", "🍔", "🌮"],
        
        // 🚗 Fahrzeuge & Transport
        ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", "🚒", "🚜", "🚂", "✈️", "🚀", "🛳"],
        
        // ⚽️ Sport & Aktivitäten
        ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🥏", "🎱", "🏓", "⛳️", "🥊", "🎿", "🏹", "🛹", "🛶", "🏋️", "🤸", "🏊", "🚴"],
        
        // 👨‍⚕️ Berufe & Kleidung
        ["👨‍⚕️", "👩‍🏫", "👨‍🍳", "👩‍🚀", "👨‍🎨", "👮", "👷", "💂", "🕵️", "🎩", "👗", "👚", "🧥", "👖", "👠", "👞", "🎓", "🦺", "🎭"],
        
        // 🛏️ Haushalt & Möbel
        ["🛏️", "🛋", "🚪", "🚿", "🛁", "🪑", "🖼", "🪞", "📺", "📻", "🎛", "🔑", "🔧", "🪚", "🧹", "🧼", "🪠", "🛠", "🔦", "🛒"],
        
        // 🌳 Natur & Wetter
        ["🌳", "🌲", "🌵", "🌺", "🌻", "🌷", "🌊", "🔥", "🌈", "❄️", "⛅️", "☔️", "⚡️", "🌪", "🌍", "🏔", "🏖", "🏜", "🏕", "🌅"],
        
        // 📱 Technologie & Medien
        ["📱", "💻", "🖥", "🖨", "🖱", "📡", "📷", "🎥", "🎙", "📺", "📞", "☎️", "⏰", "🔋", "🧮", "📡", "🛰", "💾", "🖊"],
        
        // 📖 Schule & Lernen
        ["📖", "📚", "📓", "✏️", "🖊", "🖋", "📏", "📐", "📊", "🖍", "📌", "📎", "📅", "🎨", "🔬", "🧪", "🗺", "🎼", "🎭"]
    ]
    
    var body: some View {
        VStack(spacing: 10) { // 🔹 Optimierte Abstände
            HStack {
                Text(settings.localizedText(for: "headline", in: "emojiPicker"))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding()
            
            // 🔹 Flexible Höhe statt fester Größe
            TabView(selection: $currentPage) {
                ForEach(emojiPages.indices, id: \.self) { index in
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(emojiPages[index], id: \.self) { emoji in
                            Text(emoji)
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedEmoji = emoji
                                    isPresented = false
                                }
                        }
                    }
                    .padding()
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .background(
                Color.clear
                    .onAppear {
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label // Dynamische Farbe
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.secondaryLabel // Dezente Farbe für nicht aktive Punkte
                    }
            )
            .frame(height: CGFloat((emojiPages.map { $0.count }.max() ?? 20) / 5 * 50 + 150))
            
            // 🔹 Button zum Überspringen
            Button(settings.localizedText(for: "button", in: "emojiPicker")) {
                selectedEmoji = "" // Leeres Emoji = kein Emoji
                isPresented = false
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
            .foregroundColor(.white)
            .padding()
        }
        .frame(width: 350) // Breite fixiert, Höhe flexibel
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.bottom, 10) // Etwas Abstand unten
    }
}
