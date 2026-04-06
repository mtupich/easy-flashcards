import PhotosUI
import SwiftUI

struct ProfileSheet: View {

    let userInfo: UserInfo?
    let localPhoto: UIImage?
    let onDismiss: () -> Void
    let onLogout: () -> Void
    let onDeleteAccount: () -> Void
    let onPhotoChanged: (UIImage) -> Void

    @State private var showDeleteConfirm = false
    @State private var selectedItem: PhotosPickerItem?

    private var displayName: String { userInfo?.displayName ?? "Usuário" }
    private var email: String { userInfo?.email ?? "" }
    private var photoURL: URL? { userInfo?.photoURL }
    private var initials: String { userInfo?.initials ?? "?" }

    var body: some View {
        VStack(spacing: 0) {
            sheetIndicator
            profileHeader
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 20)
            menuOptions
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "F2F2F7"))
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .alert("Tem certeza que deseja deletar sua conta?", isPresented: $showDeleteConfirm) {
            Button("Cancelar", role: .cancel) {}
            Button("Deletar", role: .destructive) {
                onDeleteAccount()
            }
        } message: {
            Text("Esta ação é irreversível. Todos os seus dados serão perdidos.")
        }
        .onChange(of: selectedItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        onPhotoChanged(image)
                    }
                }
            }
        }
    }

    private var sheetIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 20)
    }

    private var profileHeader: some View {
        HStack(spacing: 14) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                profileImage
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.accent)
                            .background(Circle().fill(.white).padding(2))
                    }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)

                if !email.isEmpty {
                    Text(email)
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                }
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private var profileImage: some View {
        if let localPhoto {
            Image(uiImage: localPhoto)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
        } else if let photoURL {
            AsyncImage(url: photoURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                initialsCircle
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())
        } else {
            initialsCircle
        }
    }

    private var initialsCircle: some View {
        Circle()
            .fill(AppTheme.accent)
            .frame(width: 52, height: 52)
            .overlay(
                Text(initials)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            )
    }

    private var menuOptions: some View {
        VStack(spacing: 0) {
            menuRow(
                icon: "creditcard",
                title: "Gerenciar Plano",
                color: .black
            ) {}

            Divider()
                .padding(.leading, 56)

            menuRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Sair da Conta",
                color: .red
            ) {
                onLogout()
            }

            Divider()
                .padding(.leading, 56)

            menuRow(
                icon: "trash",
                title: "Deletar Conta",
                color: .red
            ) {
                showDeleteConfirm = true
            }
        }
        .padding(.vertical, 8)
    }

    private func menuRow(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(color)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(color)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.gray.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}
