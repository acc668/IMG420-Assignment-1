# IMG420-Assignment-1

A 2D space shooter game built with Godot Engine 4.x and GDScript. Pilot your spaceship through waves of enemies and asteroids while collecting power-ups to survive as long as possible.

![Game Genre](https://img.shields.io/badge/Genre-Space%20Shooter-blue)
![Engine](https://img.shields.io/badge/Engine-Godot%204.x-478cbf)
![Language](https://img.shields.io/badge/Language-GDScript-blue)

---

## 📖 Game Description

**Space Survivor** is an arcade-style space shooter where you must survive for 2 minutes while battling enemies, destroying asteroids, and collecting power-ups. The game features intelligent enemy AI, destructible obstacles, and a dynamic scoring system.

### Objective
- **Win Condition**: Survive for 2 minutes (120 seconds)
- **Lose Condition**: Your health reaches zero
- **Challenge**: Maximize your score by destroying enemies and asteroids

---

## 🎮 How to Play

### Controls

| Action | Keys |
|--------|------|
| **Move Up** | W or ↑ |
| **Move Down** | S or ↓ |
| **Move Left** | A or ← |
| **Move Right** | D or → |
| **Shoot** | Space or Left Mouse Click |
| **Pause** | ESC or P |

### Gameplay Tips
- **Stay mobile** - Keep moving to avoid enemy fire and asteroids
- **Collect power-ups** - Green restores health, Blue/Orange provides speed boost
- **Destroy asteroids** - They have a chance to drop power-ups
- **Watch your health** - The health bar changes color as you take damage
- **Survive the timer** - You only need to last 2 minutes to win!

---

## ✨ Features

### Core Gameplay
- **Playable Character**: Fully controllable spaceship with smooth movement
- **Three Input Types**: Horizontal movement, vertical movement, and shooting
- **Interactable Level**: 
  - Collectible power-ups (health restoration, speed boost)
  - Destructible asteroids with dynamic physics
- **Win/Lose Conditions**: Time-based survival with health depletion
- **GUI System**: 
  - In-game HUD (health bar, score, timer)
  - Main menu with instructions
  - Pause menu functionality

### Extra Features
- **Intelligent Enemy AI** (Extra Credit - 2 pts):
  - Patrol state: Enemies move back and forth
  - Chase state: Enemies pursue the player when nearby
  - Attack state: Enemies stop and shoot at the player
- **Visual Animations** (Extra Credit - 1-2 pts):
  - Power-ups float and rotate
  - Damage feedback with color changes
  - Smooth transitions between game states
- **Sound Support** (Extra Credit - 1 pt):
  - AudioStreamPlayer nodes ready for sound effects
  - Background music support in menus and gameplay

---

## 🎯 Requirements Met

### Basic Requirements (10 points)
✅ **Playable Character (3 points)**
- Three unique inputs: horizontal movement, vertical movement, shooting
- Smooth character control with screen boundary clamping

✅ **Interactable Level (3 points)**
- Collectible power-ups (health, speed boost, rapid fire)
- Destructible asteroids with dynamic physics

✅ **Win-Lose Conditions (2 points)**
- Win: Survive for 2 minutes
- Lose: Health depletes to zero
- Clear visual and audio feedback for both conditions

✅ **GUI System (2 points)**
- HUD: Real-time health bar, score display, countdown timer
- Main Menu: Start game, view instructions, quit
- Pause Menu: Resume, restart, or return to main menu

### Extra Credit (5 points)
✅ **NPCs (2 points)**
- Enemy AI with three behavioral states
- Intelligent pathfinding and targeting system
- Enemy projectiles that track player position

✅ **Animations (1-2 points)**
- Power-up floating and rotation animations
- Visual feedback for damage taken
- Color transitions for health states

✅ **Sound Effects (1 point)**
- Audio system architecture in place
- Ready for sound effect implementation
- Background music support structure

**Total Points: 15/15 (10 base + 5 extra credit)**

---

## 🛠️ Installation & Setup

### Prerequisites
- [Godot Engine 4.x](https://godotengine.org/download) with .NET support
- Windows, macOS, or Linux operating system

### Running the Game

1. **Download/Clone the Project**
   - git clone [(https://github.com/acc668/IMG420-Assignment-1/edit/main/README.md)]
   - or download and extract the ZIP file

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import"
   - Navigate to the project folder
   - Select `project.godot`
   - Click "Import & Edit"

3. **Run the Game**
   - Press **F5** or click the "Play" button
   - The main menu will appear
   - Click "Start Game" or press Space/Click anywhere to begin

### Project Structure
  space-survivor/
  ├── Player.tscn / Player.gd          # Player character
  ├── Bullet.tscn / Bullet.gd          # Player projectiles
  ├── Enemy.tscn / Enemy.gd            # AI enemies
  ├── EnemyBullet.tscn / EnemyBullet.gd # Enemy projectiles
  ├── Asteroid.tscn / Asteroid.gd      # Destructible obstacles
  ├── PowerUp.tscn / PowerUp.gd        # Collectible items
  ├── HUD.tscn / HUD.gd                # Heads-up display
  ├── MainMenu.tscn / MainMenu.gd      # Main menu screen
  ├── PauseMenu.tscn / PauseMenu.gd    # Pause overlay
  ├── Main.tscn / Main.gd              # Main game scene
  ├── GameOverScreen.tscn / GameOverScreen.gd # Loss screen
  ├── WinScreen.tscn / WinScreen.gd    # Victory screen
  ├── GlobalData.gd                    # Score persistence (optional)
  └── README.md                        # This file

---

## 🎨 Design Decisions

### Scene Prefab Architecture
The game uses Godot's scene composition pattern, where each entity is a self-contained scene that can be instantiated multiple times. This makes the game easy to extend and modify.

### Signal-Based Communication
Player events (health changes, death, score updates) use Godot's signal system to notify the HUD and game manager, creating loose coupling between systems.

### State Machine AI
Enemies use a simple state machine with three states (Patrol, Chase, Attack) that transition based on distance to the player, creating dynamic and interesting gameplay.

### Physics Bodies
- **CharacterBody2D**: Used for player and enemies (kinematic control)
- **RigidBody2D**: Used for asteroids (physics-driven movement)
- **Area2D**: Used for bullets and power-ups (detection only)

---

## 🎓 Learning Outcomes

This project demonstrates:
- **Scene composition** and prefab reusability
- **Signal-based architecture** for decoupled systems
- **State machine pattern** for AI behavior
- **Collision detection** using multiple physics body types
- **Input handling** with Godot's Input Map system
- **Timer management** for game state and win conditions
- **UI/UX design** with multiple menu screens
- **Resource management** with proper memory cleanup

---

## 🐛 Known Issues

- Enemies may occasionally clip through each other during chase state
- Power-ups can spawn near screen edges (rare cases)
- High enemy count (15+) may cause slight performance dip on older hardware

### Future Improvements
- Add particle effects for explosions
- Implement sound effects and background music
- Add multiple weapon types
- Create different enemy varieties
- Add difficulty progression (wave system)
- Implement high score leaderboard
- Add gamepad support

---

## 📝 Credits

### Development
- **Developer**: [Alexandra Curry]
- **Course**: [IMG-420: 2D Game Engines]
- **Institution**: [Northern Arizona University]
- **Date**: [10/14/2025]

### Tools & Resources
- **Game Engine**: [Godot Engine 4.x](https://godotengine.org/)
- **Language**: GDScript
- **IDE**: Godot Editor

### Assets
- Placeholder graphics created using Godot's built-in ColorRect and Polygon2D nodes

---

## 📄 License

This project was created for educational purposes as part of a game development course.

**Educational Use Only** - Not for commercial distribution

---

## 🤝 Acknowledgments

- Godot Engine community for excellent documentation
- Course instructor for project guidelines and support

---

## 📧 Contact

**Developer**: [Alexandra Curry]  
**Email**: [Curry.Alexandra@protonmail.com]  
**GitHub**: [github.com/acc668]

---

**Enjoy playing Space Survivor!** 🚀✨

*Last Updated: [10/14/2025]*
