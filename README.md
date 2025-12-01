# 🏓 Ping Pong Game in x86 Assembly (8086 Real Mode)

A simple **Ping Pong game** written in **16-bit x86 Assembly** using BIOS interrupts, custom timer handling, and direct video memory access.  
The game runs in **80x25 text mode** and demonstrates low-level system programming concepts such as interrupt hooking, hardware keyboard handling, and VRAM manipulation.

---

## 🎮 Game Overview

This project implements a two-player Ping Pong game:

- **Player A** paddle at the top (row `0`)
- **Player B** paddle at the bottom (row `23`)
- A moving ball (`*`) bounces around the screen
- Players move paddles using **Left** and **Right arrow keys**
- A point is scored when a paddle fails to hit the incoming ball
- First player to reach **5 points** wins
- Game resets for each round and exits cleanly when finished

The internal logic manages ball movement, paddle collisions, score tracking, and display using direct writes to text-mode video memory (`0xB800`).

---

## ✨ Features

✔ Direct video memory rendering (`0xB800:0000`)  
✔ Custom **timer ISR (INT 8h)** for ball movement  
✔ Custom **keyboard ISR (INT 9h)** for paddle control  
✔ Paddle collision detection  
✔ Real-time game loop without polling  
✔ Clean restoration of original interrupt handlers  
✔ Scoreboard rendering  
✔ Ball physics with 4 movement directions  
✔ Fully standalone `.COM` executable

---

## 🧠 Technical Breakdown

### Interrupts Used
| Interrupt                   | Purpose                      |
|-----------------------------|------------------------------|
| **INT 08h (Timer IRQ0)**    | Controls ball movement speed |
| **INT 09h (Keyboard IRQ1)** | Handles arrow key input      |
| **INT 21h AH=4Ch**          | Exits program                |
| **Direct VRAM**             | Draws paddles, ball & scores |

### Important Memory Variables
- `rowposition`, `colposition` — ball coordinates  
- `direction` — ball movement direction (0–3)  
- `moveflag` — updated by timer ISR  
- `ScoreA`, `ScoreB` — player scores  
- `turn` — whose paddle to move (0=A, 1=B)  
- `tickcount` — manages ball speed

---

## 🕹 Controls

| Key               | Function          |
|-------------------|-------------------|
| **← Left Arrow**  | Move paddle left  |
| **→ Right Arrow** | Move paddle right |

The keyboard ISR automatically detects which paddle to move depending on the ball's turn.

---

## ▶️ How to Build and Run

### Requirements
- **NASM** assembler  
- **DOSBox**, **QEMU**, **Bochs**, or real DOS environment  

### Build
```bash
nasm pingpong.asm -o pingpong.com
pingpong.com
```

## 🏁 Game End

When a player reaches **5 points**:

- Timer interrupt is restored  
- Keyboard interrupt is restored  
- Program exits via DOS (`INT 21h`)  
- No TSR footprint remains  

---

## 📜 License

This project is released under the **MIT License** — feel free to use, modify, and learn from it.

---
