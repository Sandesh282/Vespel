import SwiftUI

struct AlertModal: View {
    var title: String
    var message: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
            Button(action: onDismiss) {
                Text("Dismiss")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(BlurView(style: .systemUltraThinMaterialDark))
        .cornerRadius(20)
        .padding(40)
    }
}

struct AlertModal_Previews: PreviewProvider {
    static var previews: some View {
        AlertModal(title: "Alert", message: "This is a custom alert.", onDismiss: {})
    }
}

