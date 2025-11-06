# IMG420-Assignment-1

This is a simple 2D game made in the Godot Engine using GDScript.  
It includes a playable character, an interactable level, win/lose conditions, and a basic GUI system.

## Features

- **Playable Character:** Moves left and right, jumps, and falls due to gravity.
- **Interactable Level:** Collect coins to increase your score and reach the door to win.
- **Win/Lose Conditions:**
  - Win by reaching the door after collecting at least one coin.
  - Lose if you fall off the map.
- **GUI System:** Displays the current score and includes a main menu, win screen, and lose screen.

## Controls

- **Left Arrow / A** – Move left  
- **Right Arrow / D** – Move right  
- **Space / Enter** – Jump

## Scenes

- **MainMenu.tscn:** Start screen with a "Start Game" button.  
- **Game.tscn:** Main gameplay scene.  
- **WinScreen.tscn:** Shown when the player wins.  
- **LoseScreen.tscn:** Shown when the player loses.  
- **Player.tscn:** Contains the player character and movement script.  
- **Coin.tscn:** Collectible coin that increases score.  
- **Door.tscn:** Used to trigger win condition.

## Scripts

- **MainMenu.gd:** Handles start button and scene transition.  
- **Game.gd:** Manages score, win/loss detection, and HUD updates.  
- **Player.gd:** Handles movement, jumping, gravity, and falling off map.  
- **Coin.gd:** Detects player collision, adds score, and disappears.  

## How to Run

1. Open the project in **Godot 4.x**.  
2. Set `MainMenu.tscn` as the main scene in **Project → Project Settings → Run → Main Scene**.  
3. Click **Play** to start the game.

## Requirements

- Godot Engine 4.x with .NET or Standard GDScript support.
