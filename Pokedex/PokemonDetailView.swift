import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @State private var scale: CGFloat = 1.0  // Initial scale value
    @State private var showHearts: Bool = false  // Whether the heart shower is active
    @State private var hearts: [Heart] = []  // The list of hearts to animate

    // A struct to represent each heart for the animation
    struct Heart: Identifiable {
        let id = UUID()
        var offset: CGFloat
        var opacity: Double
        var scale: CGFloat
        var rotation: Double
    }
    
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
                            .frame(width: 150, height: 150)
                            .scaleEffect(scale)  // Apply the zoom scale
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    scale = 1.5  // Zoom in effect
                                }

                                // After a short delay, zoom out
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        scale = 1.0  // Zoom out effect
                                    }
                                }
                            }
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
        .overlay(
            // Heart shower animation
            Group {
                if showHearts {
                    ForEach(hearts) { heart in
                        Text("❤️")
                            .font(.system(size: 30))
                            .offset(x: CGFloat.random(in: -UIScreen.main.bounds.width / 2...UIScreen.main.bounds.width / 2), y: heart.offset)
                            .opacity(heart.opacity)
                            .scaleEffect(heart.scale)
                            .rotationEffect(.degrees(heart.rotation))
                            .animation(
                                Animation
                                    .easeInOut(duration: Double.random(in: 0.5...1.5))
                                    .repeatForever(autoreverses: true),
                                value: heart.scale
                            )
                    }
                }
            }
        )
        .onAppear {
            if pokemon.isFavorite {
                startHeartShower()  // Trigger heart shower when Pokémon is a favorite
            }
        }
        .onChange(of: pokemon.isFavorite) { newValue in
            if newValue {
                startHeartShower()  // Trigger heart shower if the Pokémon becomes a favorite
            }
        }
        .navigationBarTitle("Détails du Pokémon", displayMode: .inline)
    }

    // Function to start the heart shower animation
    func startHeartShower() {
        showHearts = true
        hearts = []
        
        // Create hearts to animate
        for _ in 0..<80 { // Number of hearts
            let randomOffset = CGFloat.random(in: -UIScreen.main.bounds.height / 2...UIScreen.main.bounds.height / 2) // Random y offset
            let randomScale = CGFloat.random(in: 0.5...1.5) // Random scale for sparkle effect
            let randomRotation = Double.random(in: -45...45) // Random rotation
            let heart = Heart(offset: -UIScreen.main.bounds.height / 2, opacity: Double.random(in: 0.5...1.0), scale: randomScale, rotation: randomRotation) // Start from above the screen
            hearts.append(heart)
        }

        // Animate hearts falling with randomized offset behavior
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.linear(duration: 2)) {
                hearts = hearts.map {
                    Heart(offset: CGFloat.random(in: -500...500), opacity: $0.opacity, scale: $0.scale, rotation: $0.rotation)                }
            }
        }
        
        // Stop the animation after a brief duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            showHearts = false
        }
    }
}
