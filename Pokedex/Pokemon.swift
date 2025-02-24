// MARK: - Pokemon.swift
import Foundation
import CoreData

struct Pokemon: Identifiable, Codable, Equatable, Hashable {
    var id: Int
    var name: String
    var imageUrl: String
    var types: [String]
    var stats: [Stat]
    var isFavorite: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.id == rhs.id
    }

    struct Stat: Codable, Equatable, Hashable {
        var statName: String
        var baseStat: Int
    }
}

extension Pokemon {
    func toEntity(context: NSManagedObjectContext) -> PokemonEntity {
        let entity = PokemonEntity(context: context)
        entity.id = Int64(id)
        entity.name = name
        entity.imageUrl = imageUrl
        
        if let encodedTypes = try? JSONEncoder().encode(types as [String]) {
            entity.types = encodedTypes as NSData
        }
        
        if let encodedStats = try? JSONEncoder().encode(stats as [Stat]) {
            entity.stats = encodedStats as NSData
        }
        
        entity.isFavorite = isFavorite
        return entity
    }
}


extension PokemonEntity {
    func toPokemon() -> Pokemon {
        let decodedTypes = (try? JSONDecoder().decode([String].self, from: types as? Data ?? Data())) ?? []
        let decodedStats = (try? JSONDecoder().decode([Pokemon.Stat].self, from: stats as? Data ?? Data())) ?? []
        
        return Pokemon(
            id: Int(id),
            name: name ?? "",
            imageUrl: imageUrl ?? "",
            types: decodedTypes,
            stats: decodedStats,
            isFavorite: isFavorite
        )
    }
}

// MARK: - API Response Models
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
    let stats: [Stat]

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
