import SwiftUI

extension View {
    func floatingSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay {
            FloatingSheetOverlay(isPresented: isPresented, sheetContent: content)
        }
    }
}

struct FloatingSheetOverlay<SheetContent: View>: View {

    @Binding var isPresented: Bool
    @ViewBuilder let sheetContent: () -> SheetContent

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isPresented = false }
                    }

                sheetContent()
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
    }
}
