import SwiftUI

@main
struct SnakeGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var game = GameEngine()
    
    var body: some View {
        Group {
            switch game.state {
            case .menu:
                MenuView(onStart: game.startGame)
            case .countdown:
                CountdownView(count: game.countdownValue)
            case .playing:
                GameView(game: game)
            case .gameOver:
                GameOverView(winner: game.winner, onRestart: game.reset)
            }
        }
        .statusBar(hidden: true)
    }
}
