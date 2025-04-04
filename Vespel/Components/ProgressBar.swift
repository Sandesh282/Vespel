import SwiftUI

struct ProgressBar: View {
    var progress: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .foregroundColor(.pink)
            }
        }
    }
}

#Preview{
    ProgressBar()
}
