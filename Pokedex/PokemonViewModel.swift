import SwiftUI
import Combine

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []  // Liste complète des Pokémon
    @Published var filteredPokemonList: [Pokemon] = []  // Liste filtrée par type et par recherche
    @Published var searchText: String = ""  // Texte de recherche
    @Published var selectedTypes: Set<String> = []  // Types sélectionnés pour filtrer
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observation du texte de recherche
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterPokemon()
            }
            .store(in: &cancellables)
        
        // Observation des types sélectionnés
        $selectedTypes
            .sink { [weak self] _ in
                self?.filterPokemon()
            }
            .store(in: &cancellables)
    }
    
    func loadData() {
        if pokemonList.isEmpty {
            fetchPokemonList()
        } else {
            filteredPokemonList = pokemonList
        }
    }
    
    private func fetchPokemonList() {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonListResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .flatMap { [weak self] results in
                guard let self = self else {
                    return Empty<Pokemon, Error>().eraseToAnyPublisher()
                }
                let pokemonPublishers = results.map { pokemon in
                    self.fetchPokemonDetails(pokemon: pokemon)
                }
                return Publishers.MergeMany(pokemonPublishers)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching Pokémon data: \(error)")
                }
            }, receiveValue: { [weak self] pokemon in
                self?.addPokemonIfNotExists(pokemon)
            })
            .store(in: &cancellables)
    }
    
    private func addPokemonIfNotExists(_ pokemon: Pokemon) {
        if !pokemonList.contains(where: { $0.id == pokemon.id }) {
            pokemonList.append(pokemon)
            filteredPokemonList = pokemonList  // Mise à jour de la liste filtrée avec tous les Pokémon
        }
    }
    
    private func fetchPokemonDetails(pokemon: PokemonResponse) -> AnyPublisher<Pokemon, Error> {
        let url = URL(string: pokemon.url)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonDetails.self, decoder: JSONDecoder())
            .map { details in
                Pokemon(
                    id: Int(pokemon.url.hash),
                    name: pokemon.name,
                    imageUrl: details.sprites.front_default,
                    types: details.types.map { $0.type.name },
                    stats: details.stats.map { stat in
                        Pokemon.Stat(statName: stat.stat.name, baseStat: stat.base_stat)
                    },
                    isFavorite: false
                )
            }
            .eraseToAnyPublisher()
    }
    
    // Filtrage des Pokémon en fonction du texte de recherche et des types sélectionnés
    func filterPokemon() {
        filteredPokemonList = pokemonList.filter { pokemon in
            let matchesSearchText = searchText.isEmpty || pokemon.name.lowercased().contains(searchText.lowercased())
            
            let matchesType = selectedTypes.isEmpty || !Set(pokemon.types).isDisjoint(with: selectedTypes)
            
            return matchesSearchText && matchesType
        }
    }
}
