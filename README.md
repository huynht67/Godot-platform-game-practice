**Godot Platform Game Practice**

A 2D action platformer prototype built with Godot 4, focused on responsive combat, multi-form abilities, and polished moment-to-moment gameplay feel.

This project serves as both a technical learning project exploring gameplay systems, architecture, and debugging, and an indie-style prototype demonstrating combat design, animation flow, and player feedback.

**Gameplay Overview**

The player can switch between four combat forms, each with distinct attack behavior:

Base Form – standard forward melee slash

Blue Form – ranged projectile attack

Green Form – shorter, tighter melee hitbox

Purple Form – circular area-of-effect attack

Core combat features implemented:

- Directional melee hitboxes with per-form tuning

- Projectile shooting with correct facing and spawn positioning

- Animation state switching per form

- Attack, hit, and death sound effects

- Enemy damage handling and death behavior

All player character sprites and animations were hand-drawn using LibreSprite.

The current focus of the prototype is combat responsiveness, feel, and scalable system design, rather than full game content.

**Controls**
Action	Key
Move Left / Right	A / D or Arrow Keys
Jump	Space
Attack	C
Change Form	Q
Technical Highlights

Built using Godot 4 and GDScript

Modular multi-form combat architecture

Runtime hitbox shape swapping (rectangle ↔ circle)

Clean audio routing per action and form

Separation of visual transforms vs. collision logic

Structured for future scalability (new forms, enemies, abilities)



**Project Status**

Current state:

Core combat system is functional and playable.

Planned next steps:

- Player health, damage, and respawn system

- Enemy AI (patrol, chase, attack)

- Screen shake and hit-pause polish

- UI and level progression

- Playable demo build

**Learning Resources & Inspiration**

This project was initially inspired by tutorials from Brackeys, which provided foundational guidance on movement and project structure in Godot.

All combat systems, multi-form mechanics, hitbox logic, audio integration, and subsequent gameplay features were independently extended and implemented as part of continued learning and experimentation.

**Assets & Credits**

Art & Animation:
The stage were built using Brackeys' Platformer Bundle.
Source: https://brackeysgames.itch.io/brackeys-platformer-bundle
Player character sprites and animations were originally hand-drawn by the author using LibreSprite.

Music:
Lofi hip hop Volume 1) - 06 - Soft Lights (Loop Version) by Jeremy Leaird-Koch is licensed under a CC BY-NC license. 
Source: https://jjbbllkk.itch.io/ 
Artist: https://rmr.media/

Sound Effects:
Weapon, hit, and death sound effects obtained from royalty-free audio libraries suitable for educational use.

**Getting Started**

Install Godot 4.x

Clone this repository:

git clone https://github.com/huynht67/Godot-platform-game-practice.git


Open the project using project.godot

Press Play to run the main scene

**Author**

Tuan Q Huynh
UH Computer Science student 

**Future Vision**

This prototype represents a foundation toward building a fully playable indie-scale action platformer, with emphasis on:

- Satisfying combat feel

- Scalable gameplay systems

- Polished player feedback

- Clean, maintainable code architecture
