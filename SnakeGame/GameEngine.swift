import SwiftUI
import Combine
import AVFoundation

enum GameState {
    case menu, countdown, playing, gameOver
}

class GameEngine: ObservableObject {
    @Published var state: GameState = .menu
    @Published var snakes: [Snake] = []
    @Published var mousePosition: Position?
    @Published var countdownValue: Int = 3
    @Published var winner: PlayerColor?
    
    let gridWidth = 50
    let gridHeight = 35
    private var timer: Timer?
    private var mouseTimer: Timer?
    private var speedTimer: Timer?
    private var countdownTimer: Timer?
    private var baseInterval: TimeInterval = 0.15
    private var currentInterval: TimeInterval = 0.15
    private var audioPlayer: AVAudioPlayer?
    
    func startGame(playerCount: Int) {
        setupSnakes(count: playerCount)
        state = .countdown
        countdownValue = 3
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.countdownValue -= 1
            if self.countdownValue == 0 {
                self.countdownTimer?.invalidate()
                self.beginPlaying()
            }
        }
    }
    
    private func beginPlaying() {
        state = .playing
        spawnMouse()
        
        timer = Timer.scheduledTimer(withTimeInterval: currentInterval, repeats: true) { [weak self] _ in
            self?.update()
        }
        
        mouseTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.spawnMouse()
        }
        
        speedTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.increaseSpeed()
        }
    }
    
    private func setupSnakes(count: Int) {
        let colors: [PlayerColor] = [.green, .red, .blue, .yellow]
        let starts: [(Position, Direction)] = [
            (Position(x: 3, y: 3), .right),
            (Position(x: gridWidth - 4, y: 3), .left),
            (Position(x: 3, y: gridHeight - 4), .right),
            (Position(x: gridWidth - 4, y: gridHeight - 4), .left)
        ]
        
        snakes = (0..<count).map { i in
            let (pos, dir) = starts[i]
            return Snake(
                body: [pos, Position(x: pos.x - (dir == .right ? 1 : -1), y: pos.y), 
                       Position(x: pos.x - (dir == .right ? 2 : -2), y: pos.y)],
                direction: dir,
                nextDirection: dir,
                color: colors[i]
            )
        }
    }
    
    private func update() {
        var grow = [Bool](repeating: false, count: snakes.count)
        
        // Move all snakes first
        for i in snakes.indices where snakes[i].isAlive {
            snakes[i].move(grow: false)
            snakes[i].body = snakes[i].body.map { $0.wrapped(width: gridWidth, height: gridHeight) }
        }
        
        // Check food collision after moving
        for i in snakes.indices where snakes[i].isAlive {
            if let mousePos = mousePosition, snakes[i].head == mousePos {
                grow[i] = true
                mousePosition = nil
                break
            }
        }
        
        // Grow snakes that ate food
        for i in snakes.indices where grow[i] {
            let tail = snakes[i].body.last!
            snakes[i].body.append(tail)
        }
        
        checkCollisions()
        
        let aliveCount = snakes.filter { $0.isAlive }.count
        if aliveCount <= 1 {
            endGame()
        }
    }
    
    private func checkCollisions() {
        var heads: [Position: [Int]] = [:]
        
        for i in snakes.indices where snakes[i].isAlive {
            let head = snakes[i].head
            heads[head, default: []].append(i)
        }
        
        for (_, indices) in heads where indices.count > 1 {
            for i in indices {
                killSnake(i)
            }
        }
        
        for i in snakes.indices where snakes[i].isAlive {
            let head = snakes[i].head
            
            for j in snakes.indices where snakes[j].isAlive {
                let bodyToCheck = i == j ? Array(snakes[j].body.dropFirst()) : snakes[j].body
                if bodyToCheck.contains(head) {
                    killSnake(i)
                    break
                }
            }
        }
    }
    
    private func killSnake(_ index: Int) {
        snakes[index].isAlive = false
        playDeathSound()
    }
    
    private func spawnMouse() {
        let occupied = Set(snakes.flatMap { $0.body })
        var pos: Position
        repeat {
            pos = Position(x: Int.random(in: 0..<gridWidth), y: Int.random(in: 0..<gridHeight))
        } while occupied.contains(pos)
        mousePosition = pos
    }
    
    private func increaseSpeed() {
        currentInterval *= 0.9
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: currentInterval, repeats: true) { [weak self] _ in
            self?.update()
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        mouseTimer?.invalidate()
        speedTimer?.invalidate()
        
        winner = snakes.first { $0.isAlive }?.color
        state = .gameOver
    }
    
    func reset() {
        timer?.invalidate()
        mouseTimer?.invalidate()
        speedTimer?.invalidate()
        countdownTimer?.invalidate()
        currentInterval = baseInterval
        mousePosition = nil
        state = .menu
    }
    
    func handleSwipe(player: Int, direction: Direction) {
        guard player < snakes.count, snakes[player].isAlive else { return }
        snakes[player].changeDirection(direction)
    }
    
    func turnLeft(player: Int) {
        guard player < snakes.count, snakes[player].isAlive else { return }
        let current = snakes[player].direction
        let newDir: Direction
        switch current {
        case .up: newDir = .left
        case .left: newDir = .down
        case .down: newDir = .right
        case .right: newDir = .up
        }
        snakes[player].changeDirection(newDir)
    }
    
    func turnRight(player: Int) {
        guard player < snakes.count, snakes[player].isAlive else { return }
        let current = snakes[player].direction
        let newDir: Direction
        switch current {
        case .up: newDir = .right
        case .right: newDir = .down
        case .down: newDir = .left
        case .left: newDir = .up
        }
        snakes[player].changeDirection(newDir)
    }
    
    private func playDeathSound() {
        guard let url = Bundle.main.url(forResource: "death", withExtension: "mp3") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }
}
