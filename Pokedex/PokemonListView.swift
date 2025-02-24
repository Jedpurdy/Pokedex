import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonViewModel()

    let allTypes: [(display: String, value: String)] = [
        ("🌍 All", "All"),
        ("⚪ Normal", "normal"),
        ("🔥 Fire", "fire"),
        ("🥊 Fighting", "fighting"),
        ("💧 Water", "water"),
        ("🕊️ Flying", "flying"),
        ("🌿 Grass", "grass"),
        ("☠️ Poison", "poison"),
        ("⚡ Electric", "electric"),
        ("🏔️ Ground", "ground"),
        ("🔮 Psychic", "psychic"),
        ("🪨 Rock", "rock"),
        ("❄️ Ice", "ice"),
        ("🐛 Bug", "bug"),
        ("🐉 Dragon", "dragon"),
        ("👻 Ghost", "ghost"),
        ("🌑 Dark", "dark"),
        ("⚙️ Steel", "steel"),
        ("🧚 Fairy", "fairy"),
        ("✨ Stellar", "stellar"),
        ("❓???", "???")
    ]
    
    let sortOptions: [(display: String, value: PokemonViewModel.SortOption)] = [
        ("🔠 Alphabétique", .alphabetical),
        ("💪 Attaque", .attack),
        ("❤️ Points de Vie", .hp)
    ]

    @State private var isFilterMenuVisible: Bool = false
    @State private var isSortMenuVisible: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                DisclosureGroup("Filter & Sort Options") {
                    VStack {
                        Text("Filtrer par type : ")
                        HStack {
                            Picker("Select Type", selection: $viewModel.selectedType) {
                                ForEach(allTypes, id: \.value) { type in
                                    Text(type.display).tag(type.value)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .transition(.slide)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedType)
                        }

                        Text("Trier par : ")
                        HStack {
                            Picker("Trier par", selection: $viewModel.sortOption) {
                                ForEach(sortOptions, id: \.value) { option in
                                    Text(option.display).tag(option.value)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.sortOption)

                            Picker("Ordre", selection: $viewModel.isAscending) {
                                Text("⬆️ Croissant").tag(true)
                                Text("⬇️ Décroissant").tag(false)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.isAscending)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .animation(.easeInOut(duration: 0.3), value: isFilterMenuVisible)

                // Search bar for Pokémon
                SearchBar(text: $viewModel.searchText)
                    .padding(2)
                
                // Pokémon list with animations for added/removed rows
                List(viewModel.filteredPokemonList) { pokemon in
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
                    .transition(.move(edge: .top)) // Animate when a new row is added
                    .animation(.easeInOut(duration: 0.3), value: viewModel.filteredPokemonList) // Apply animation to list changes
                }
                .navigationTitle("Pokémon")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: FavoritesView()) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onAppear {
                    viewModel.loadData()
                }
            }
        }
    }
}
