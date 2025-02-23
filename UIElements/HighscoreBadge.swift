import SwiftUI

struct HighscoreBadge: View {
    let score: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.black)
            
            Text("\(text):")
                .font(.caption)
                .foregroundColor(.black)
            
            Text("\(score)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .padding(10)
        .background(Capsule().fill(Color.yellow))
    }
}
