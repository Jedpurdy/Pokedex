import SwiftUI
struct FavoritesView: View {
    @EnvironmentObject var viewModel: PokemonViewModel

    var body: some View {
                VStack {
                    List(viewModel.favoritedPokemon) { pokemon in
                        HStack {
                            AsyncImage(url: URL(string: pokemon.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                @unknown default:
                                    EmptyView()
                                }
                            }

                            Text(pokemon.name.capitalized)
                                .font(.headline)

                            Spacer()

                            Button(action: {
                                viewModel.toggleFavorite(for: pokemon)
                            }) {
                                Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(pokemon.isFavorite ? .red : .gray)
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 8)
                        .background(NavigationLink("", destination: PokemonDetailView(pokemon: pokemon)).opacity(0))
                    }
                    .navigationTitle("Favorites")
                    .onAppear {
                        viewModel.loadData()
                    }
                }
            }
        
}
