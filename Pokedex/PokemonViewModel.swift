import SwiftUI
import Combine
import CoreData
import UserNotifications

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    
    @Published var searchText: String = ""
    @Published var selectedType: String = "All"
    @Published var sortOption: SortOption = .alphabetical
    @Published var isAscending: Bool = true

    enum SortOption {
        case alphabetical, attack, hp
    }
    
    // Computed property pour les favoris
    var favoritedPokemon: [Pokemon] {
        pokemonList.filter { $0.isFavorite }
    }
    
    // Liste filtrée et triée des Pokémon
    var filteredPokemonList: [Pokemon]  {
        var filtered = pokemonList.filter { pokemon in
            let matchesSearchText = searchText.isEmpty || pokemon.name.lowercased().contains(searchText.lowercased())
            let matchesType = selectedType == "All" || pokemon.types.contains(selectedType.lowercased())
            return matchesSearchText && matchesType
        }
        
        // Appliquer le tri selon l’option choisie
        switch sortOption {
        case .alphabetical:
            filtered.sort { isAscending ? ($0.name < $1.name) : ($0.name > $1.name) }
        case .attack:
            filtered.sort { isAscending ?
                (($0.stats.first { $0.statName == "attack" }?.baseStat ?? 0) <
                 ($1.stats.first { $0.statName == "attack" }?.baseStat ?? 0)) :
                (($0.stats.first { $0.statName == "attack" }?.baseStat ?? 0) >
                 ($1.stats.first { $0.statName == "attack" }?.baseStat ?? 0))
            }
        case .hp:
            filtered.sort { isAscending ?
                (($0.stats.first { $0.statName == "hp" }?.baseStat ?? 0) <
                 ($1.stats.first { $0.statName == "hp" }?.baseStat ?? 0)) :
                (($0.stats.first { $0.statName == "hp" }?.baseStat ?? 0) >
                 ($1.stats.first { $0.statName == "hp" }?.baseStat ?? 0))
            }
        }
        
        return filtered
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        // Mise à jour automatique des filtres et tri
        $searchText.combineLatest($selectedType, $sortOption)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Request Notification Permission
        requestNotificationPermission()
    }
    
    // Request permission for notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted for notifications.")
            } else {
                print("Permission denied for notifications.")
            }
        }
    }

    // Schedule a daily reminder for a random Pokémon
    func scheduleDailyPokemonNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Découvre un Pokémon !"
        content.body = "Il est temps de découvrir un Pokémon aléatoire !"
        content.sound = .default
        
        // Configure the time for the daily reminder (8 AM)
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyPokemonReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de l'ajout de la notification quotidienne : \(error.localizedDescription)")
            } else {
                print("Notification quotidienne planifiée")
            }
        }
    }
    
    // Simulate a type change for the favorite Pokémon
    func simulateFavoritePokemonTypeChange() {
        guard var favorite = favoritedPokemon.first else { return }

        // Randomly change the type of the favorite Pokémon
        let newType = ["fire", "water", "grass", "electric"].randomElement() ?? "normal"
        favorite.types.append(newType)
        
        // Notify the user of the type change
        scheduleFavoritePokemonTypeChangeNotification(for: favorite)
    }

    // Schedule a notification when the favorite Pokémon changes type
    func scheduleFavoritePokemonTypeChangeNotification(for pokemon: Pokemon) {
        let content = UNMutableNotificationContent()
        content.title = "Changement de type pour \(pokemon.name.capitalized) !"
        content.body = "\(pokemon.name.capitalized) a changé de type ! Découvrez son nouveau type."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: "favoritePokemonTypeChange", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de l'ajout de la notification de changement de type : \(error.localizedDescription)")
            } else {
                print("Notification de changement de type planifiée")
            }
        }
    }
    
    func loadData() {
        loadPokemonFromCoreData()
        
        if pokemonList.isEmpty {
            fetchPokemonList()
            print("Fetched Pokémon from API")
        }
    }
    
    private func loadPokemonFromCoreData() {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            pokemonList = entities.map { $0.toPokemon() }
            print("Pokémon fetched from Core Data")
        } catch {
            print("Failed to fetch Pokémon from Core Data: \(error)")
        }
    }
    
    private func savePokemon(_ pokemon: Pokemon) {
        let context = coreDataManager.context
        _ = pokemon.toEntity(context: context)
        coreDataManager.saveContext()
    }
    
    func toggleFavorite(for pokemon: Pokemon) {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)
        
        do {
            let entities = try context.fetch(fetchRequest)
            if let entity = entities.first {
                entity.isFavorite.toggle()
                coreDataManager.saveContext()
                
                if let index = pokemonList.firstIndex(where: { $0.name == pokemon.name }) {
                    pokemonList[index].isFavorite.toggle()
                }
            } else {
                print("No matching Pokémon found in Core Data.")
            }
        } catch {
            print("Failed to toggle favorite: \(error)")
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
                let pokemonPublishers = results.map { self.fetchPokemonDetails(pokemon: $0) }
                return Publishers.MergeMany(pokemonPublishers).eraseToAnyPublisher()
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
            savePokemon(pokemon)
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
}
