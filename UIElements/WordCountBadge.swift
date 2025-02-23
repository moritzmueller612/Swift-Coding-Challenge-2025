import SwiftUI

struct WordCountBadge: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "book.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.white)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(6)
        .background(Capsule().fill(Color.blue))
    }
}
