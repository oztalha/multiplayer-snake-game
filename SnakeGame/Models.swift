import Foundation

struct Position: Equatable, Hashable {
    var x: Int
    var y: Int
    
    func wrapped(width: Int, height: Int) -> Position {
        Position(
            x: (x + width) % width,
            y: (y + height) % height
        )
    }
}

enum Direction {
    case up, down, left, right
    
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}

struct Snake {
    var body: [Position]
    var direction: Direction
    var nextDirection: Direction
    var color: PlayerColor
    var isAlive: Bool = true
    
    var head: Position { body.first! }
    
    mutating func move(grow: Bool) {
        direction = nextDirection
        let newHead = nextHead()
        body.insert(newHead, at: 0)
        if !grow {
            body.removeLast()
        }
    }
    
    func nextHead() -> Position {
        let head = self.head
        switch direction {
        case .up: return Position(x: head.x, y: head.y - 1)
        case .down: return Position(x: head.x, y: head.y + 1)
        case .left: return Position(x: head.x - 1, y: head.y)
        case .right: return Position(x: head.x + 1, y: head.y)
        }
    }
    
    mutating func changeDirection(_ newDir: Direction) {
        if newDir != direction.opposite {
            nextDirection = newDir
        }
    }
}

enum PlayerColor: CaseIterable {
    case green, red, blue, yellow
    
    var name: String {
        switch self {
        case .green: return "Green"
        case .red: return "Red"
        case .blue: return "Blue"
        case .yellow: return "Yellow"
        }
    }
}
