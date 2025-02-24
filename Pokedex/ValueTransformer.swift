import Foundation

// Custom ValueTransformer for [String] (Pokémon types)
@objc(PokemonTypesTransformer)
class PokemonTypesTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let types = value as? [String] else { return nil }
        return try? JSONEncoder().encode(types)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([String].self, from: data)
    }
}

// Custom ValueTransformer for [Pokemon.Stat] (Pokémon stats)
@objc(PokemonStatsTransformer)
class PokemonStatsTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let stats = value as? [Pokemon.Stat] else { return nil }
        return try? JSONEncoder().encode(stats)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([Pokemon.Stat].self, from: data)
    }
}
