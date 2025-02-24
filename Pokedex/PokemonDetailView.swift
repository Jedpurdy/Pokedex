import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon

    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: pokemon.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }

                Text(pokemon.name.capitalized)
                    .font(.largeTitle)
                    .padding()

                Text("Types:")
                    .font(.title2)
                    .padding(.top)

                // Display Pokémon types
                ForEach(pokemon.types, id: \.self) { pokemonType in
                    Text(pokemonType.capitalized)
                        .font(.title3)
                        .foregroundColor(.blue)
                }

                Text("Stats:")
                    .font(.title2)
                    .padding(.top)

                // Display Pokémon stats
                ForEach(pokemon.stats, id: \.statName) { stat in
                    HStack {
                        Text(stat.statName)
                            .font(.body)
                        Spacer()
                        Text("\(stat.baseStat)")
                            .font(.body)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Détails du Pokémon", displayMode: .inline)
    }
}
