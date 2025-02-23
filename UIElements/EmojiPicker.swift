import SwiftUI

struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    @Binding var isPresented: Bool
    
    @ObservedObject var settings: Settings
    
    @State private var currentPage = 0
    
    private let emojiPages: [[String]] = [
        // Emotions & Faces
        ["😀", "😂", "😊", "😍", "😎", "😢", "😭", "😡", "😱", "🤯", "😴", "🤢", "😷", "🤕", "🥳", "🤓", "🥺", "😇", "😜"],
        
        // Household & Furniture
        ["🛏️", "🚪", "🛋", "🚿", "🛁", "🪑", "📺", "🖼", "🪞", "🔑", "🛠", "🧹", "🧼", "🍽", "🪟", "🗑"],
        
        // Food & Drinks
        ["🍎", "🍊", "🍌", "🍉", "🍇", "🍓", "🍒", "🥑", "🥕", "🥦", "🌽", "🍞", "🧀", "🥩", "🥗", "☕️", "🥤", "🍷", "🍺", "🍦"],
        
        // Transportation & Vehicles
        ["🚗", "🚕", "🚌", "🚎", "🚓", "🚑", "🚒", "🚂", "✈️", "🚀", "🛳", "🚤", "🚲", "🏍", "🚉", "🚠", "🛴", "🛣️"],
        
        // Clothing & Accessories
        ["👕", "👖", "🧥", "👗", "👚", "👔", "🩳", "🧦", "👟", "👠", "🧢", "🕶", "🎒", "👜", "👒"],
        
        // Professions & Work
        ["👨‍⚕️", "👩‍🏫", "👨‍🍳", "👮", "👷", "💂", "🕵️", "💼", "🎨", "👩‍💻", "👨‍🔬", "🛠", "⚖️", "🏢", "📄", "🖊", "🖥", "☎️"],
        
        // 🌍 Nature & Weather (Weather & outdoor words)
        ["🌳", "🌲", "🌻", "🌷", "🌊", "🔥", "🌈", "❄️",   "☀️", "☁️", "☔️", "⚡️", "🌪", "🏔", "🏖", "🏜", "🌅"],
        
        // Places & Buildings
        ["🏠", "🏢", "🏫", "🏥", "🏬", "🏦", "🏛", "🏪", "🗽", "🏯", "🕌", "🏰", "🛕", "⛪️", "🏨", "🚉", "🛤"],
        
        // 📱 Technology & Media
        ["📱", "💻", "🖥", "🖨", "📷", "🎥", "🎙", "📺", "☎️", "⏰", "🔋", "🛰", "💾", "🖊", "📡"],
        
        // Education & Learning
        ["📖", "📚", "📓", "✏️", "🖊", "📏", "📐", "📊", "🖍", "📌", "📎", "📅", "🔬", "🧪", "🗺", "📔"],
        
        // Shopping & Money
        ["🛍", "🛒", "💰", "💳", "🏧", "💵", "💶", "💷", "💴", "💸", "🏷", "🎁"],
        
        // People & Family
        ["👶", "👧", "🧒", "👦", "👩", "👨", "🧑", "👵", "👴", "👫", "🧑‍🤝‍🧑"],
        
        // Countries & Travel
        ["🗺", "🌍", "🏕", "🏜", "🗽", "🏯", "🕌", "🏰", "🛫", "🎢", "🌇"]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
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
            
            TabView(selection: $currentPage) {
                ForEach(emojiPages.indices, id: \.self) { index in
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(emojiPages[index], id: \.self) { emoji in
                            Text(emoji)
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
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
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.secondaryLabel
                    }
            )
            .frame(height: CGFloat((emojiPages.map { $0.count }.max() ?? 20) / 5 * 50 + 150))
            
            Button(settings.localizedText(for: "button", in: "emojiPicker")) {
                selectedEmoji = ""
                isPresented = false
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
            .foregroundColor(.white)
            .padding()
        }
        .frame(maxWidth: 350)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding()
    }
}
