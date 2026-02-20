import SwiftUI

struct MenuView: View {
    let onStart: (Int) -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("SNAKE")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    ForEach([2, 3, 4], id: \.self) { count in
                        Button(action: { onStart(count) }) {
                            Text("\(count) Players")
                                .font(.system(size: 40))
                                .foregroundColor(.black)
                                .frame(width: 300, height: 80)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

struct CountdownView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            Text("\(count)")
                .font(.system(size: 150, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct GameOverView: View {
    let winner: PlayerColor?
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                if let winner = winner {
                    Text("\(winner.name) Wins!")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(colorFor(winner))
                } else {
                    Text("Draw!")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Button(action: onRestart) {
                    Text("Play Again")
                        .font(.system(size: 40))
                        .foregroundColor(.black)
                        .frame(width: 300, height: 80)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func colorFor(_ player: PlayerColor) -> Color {
        switch player {
        case .green: return .green
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }
}

struct GameView: View {
    @ObservedObject var game: GameEngine
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                Canvas { context, size in
                    let cellWidth = size.width / CGFloat(game.gridWidth)
                    let cellHeight = size.height / CGFloat(game.gridHeight)
                    
                    for snake in game.snakes where snake.isAlive {
                        let color = colorFor(snake.color)
                        for (index, pos) in snake.body.enumerated() {
                            let rect = CGRect(
                                x: CGFloat(pos.x) * cellWidth,
                                y: CGFloat(pos.y) * cellHeight,
                                width: cellWidth,
                                height: cellHeight
                            )
                            context.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(color))
                            
                            if index == 0 {
                                let eyeSize = cellWidth * 0.2
                                let eye1 = CGRect(x: rect.midX - cellWidth * 0.25, y: rect.midY - cellHeight * 0.15, width: eyeSize, height: eyeSize)
                                let eye2 = CGRect(x: rect.midX + cellWidth * 0.05, y: rect.midY - cellHeight * 0.15, width: eyeSize, height: eyeSize)
                                context.fill(Path(ellipseIn: eye1), with: .color(.black))
                                context.fill(Path(ellipseIn: eye2), with: .color(.black))
                            }
                        }
                    }
                    
                    if let mousePos = game.mousePosition {
                        let rect = CGRect(
                            x: CGFloat(mousePos.x) * cellWidth,
                            y: CGFloat(mousePos.y) * cellHeight,
                            width: cellWidth,
                            height: cellHeight
                        )
                        context.fill(Path(ellipseIn: rect.insetBy(dx: 2, dy: 2)), with: .color(.gray))
                        
                        let earSize = cellWidth * 0.3
                        let ear1 = CGRect(x: rect.minX + cellWidth * 0.2, y: rect.minY, width: earSize, height: earSize)
                        let ear2 = CGRect(x: rect.maxX - cellWidth * 0.5, y: rect.minY, width: earSize, height: earSize)
                        context.fill(Path(ellipseIn: ear1), with: .color(.gray))
                        context.fill(Path(ellipseIn: ear2), with: .color(.gray))
                    }
                }
                
                ForEach(0..<game.snakes.count, id: \.self) { i in
                    joystick(for: i, in: geometry.size)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func joystick(for player: Int, in size: CGSize) -> some View {
        let positions: [(x: CGFloat, y: CGFloat)] = [
            (x: 80, y: 80),
            (x: size.width - 80, y: 80),
            (x: 80, y: size.height - 80),
            (x: size.width - 80, y: size.height - 80)
        ]
        
        let color = colorFor(game.snakes[player].color)
        let pos = positions[player]
        
        return ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 150, height: 150)
            
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
        }
        .position(x: pos.x, y: pos.y)
        .gesture(
            DragGesture(minimumDistance: 15)
                .onChanged { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    
                    let direction: Direction
                    if abs(dx) > abs(dy) {
                        direction = dx > 0 ? .right : .left
                    } else {
                        direction = dy > 0 ? .down : .up
                    }
                    
                    game.setDirection(player: player, direction: direction)
                }
        )
    }
    
    private func colorFor(_ player: PlayerColor) -> Color {
        switch player {
        case .green: return .green
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }
}
