import Foundation

struct Pokemon: Identifiable, Codable {
    var id: Int
    var name: String
    var imageUrl: String
    var types: [String]  // Liste des types du Pokémon
    var stats: [Stat]    // Liste des statistiques du Pokémon
    var isFavorite: Bool

    struct Stat: Codable {
        var statName: String
        var baseStat: Int
    }
}

struct PokemonListResponse: Codable {
    let results: [PokemonResponse]
}

struct PokemonResponse: Codable {
    let name: String
    let url: String
}

struct PokemonDetails: Codable {
    let sprites: Sprites
    let types: [PokemonType]
    let stats: [Stat]  // Les statistiques du Pokémon

    struct Sprites: Codable {
        let front_default: String
    }

    struct PokemonType: Codable {
        let type: TypeInfo

        struct TypeInfo: Codable {
            let name: String
        }
    }

    struct Stat: Codable {
        let stat: StatInfo
        let base_stat: Int

        struct StatInfo: Codable {
            let name: String
        }
    }
}
