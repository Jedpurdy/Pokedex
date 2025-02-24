import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var searchText = ""  // Stocke le texte de recherche

    var filteredPokemons: [Pokemon] {
        if searchText.isEmpty {
            return viewModel.pokemonList  // Si aucun texte n'est saisi, retourne tous les Pokémon
        } else {
            return viewModel.pokemonList.filter {
                $0.name.lowercased().contains(searchText.lowercased())  // Filtre par nom
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Barre de recherche
                SearchBar(text: $searchText)
                    .padding()

                // Liste des Pokémon filtrée par la recherche
                List(filteredPokemons) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                        HStack {
                            AsyncImage(url: URL(string: pokemon.imageUrl)) { image in
                                image.resizable()
                                     .scaledToFit()
                                     .frame(width: 50, height: 50)
                            } placeholder: {
                                ProgressView()
                            }

                            Text(pokemon.name.capitalized)
                                .font(.headline)
                        }
                    }
                }
                .navigationTitle("Pokémon")
                .task {
                    await viewModel.loadData()
                }
            }
        }
    }
}

struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView()
    }
}
