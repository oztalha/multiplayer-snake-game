# Multiplayer Snake Game

A 2-4 player Snake game for iPad built with SwiftUI. Each player controls their snake from a corner of the screen using intuitive joystick controls.

## Features

- **2-4 Players** - Select number of players from the menu
- **Joystick Controls** - Virtual joystick in each corner for directional control
- **Color-Coded Players**
  - Player 1 (Top-left): Green
  - Player 2 (Top-right): Red
  - Player 3 (Bottom-left): Blue
  - Player 4 (Bottom-right): Yellow
- **Screen Wrapping** - No walls, snakes wrap around edges
- **Dynamic Difficulty** - Speed increases 10% every 30 seconds
- **Food System** - Cartoonish mouse spawns every 5 seconds
- **Last Snake Standing** - Winner is the last snake alive

## Requirements

- iPad running iOS 18.0 or later
- Xcode 15.0 or later
- Optimized for iPad Pro 12.9" in landscape mode

## Installation

1. Clone the repository:
```bash
git clone https://github.com/oztalha/multiplayer-snake-game.git
cd multiplayer-snake-game
```

2. Open the project in Xcode:
```bash
open SnakeGame.xcodeproj
```

3. Select your iPad device or simulator

4. Build and run (⌘R)

## How to Play

1. Launch the app and select 2, 3, or 4 players
2. After the countdown, control your snake using the joystick in your corner
3. Drag the joystick in any direction (up/down/left/right) to move your snake
4. Eat mice to grow longer
5. Avoid colliding with other snakes
6. Last snake alive wins!

## Game Rules

- Snakes start with 3 segments in their respective corners
- Eating a mouse grows the snake by 1 segment
- Head-to-head collision kills both snakes
- Hitting another snake's body kills only the colliding snake
- Screen edges wrap around (no walls)
- Game speed increases gradually over time

## Technical Details

- Built with SwiftUI and Combine
- Canvas-based rendering for smooth gameplay
- Timer-based game loop
- Grid size: 50x35 cells
- Base speed: 0.15 seconds per move
- Landscape-only orientation

## Project Structure

```
SnakeGame/
├── SnakeGameApp.swift    # App entry point and state management
├── Models.swift          # Game data structures (Snake, Position, Direction)
├── GameEngine.swift      # Game logic, collision detection, timers
└── Views.swift           # UI components (Menu, Game, GameOver, Countdown)
```

## License

MIT License - feel free to use and modify!

## Credits

Created with SwiftUI for iPad multiplayer gaming.
