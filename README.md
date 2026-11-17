# GRAB THE KEY AND OPEN THE DOOR 🗝️🚪

![Género](https://img.shields.io/badge/G%C3%A9nero-Plataformas_2D-blue)
![Estilo](https://img.shields.io/badge/Estilo-Pixel_Art-green)
![Motor](https://img.shields.io/badge/Motor-Godot_Engine-478CBF?logo=godot-engine&logoColor=white)

Un videojuego de plataformas 2D en Pixel Art desarrollado en **Godot Engine**. Pensado para jugadores casuales que buscan mecánicas sencillas de precisión y destreza.

## 📖 Historia y Objetivo
Un explorador se adentra en un entorno de plataformas con una única misión: **recuperar una llave perdida** en cada zona. Esta llave es el único artefacto capaz de abrir la puerta de salida que le permitirá avanzar al siguiente nivel.

## 🎮 Mecánicas de Juego

*   **Niveles:** El juego consta de 10 niveles (escenas) independientes.
*   **Objetivo principal:** Esquivar obstáculos, alcanzar la llave y llegar a la puerta de salida para cargar el siguiente nivel.
*   **Sistema de Vidas:** 
    *   El jugador inicia cada nivel con **3 corazones**.
    *   Caer al vacío o tocar un obstáculo resta 1 corazón y reaparece al jugador al inicio del nivel actual.
    *   Perder los 3 corazones en un mismo nivel provoca un *Game Over* y regresa al jugador al Menú Principal.
    *   Al superar un nivel, las vidas se restablecen a 3.
*   **Obstáculos y Entorno:** El jugador deberá interactuar con piedras fijas y lianas para columpiarse o atravesar grandes vacíos. 
*   **Puntuación:** El progreso se mide de forma sencilla mediante un contador de niveles completados (ej. Nivel $1/10$). No hay límite de tiempo.

## 👾 Personaje y Controles
*   **Protagonista:** Explorador con traje básico en Pixel Art de baja resolución.
*   **Movimiento:** Animaciones básicas de caminar, saltar y estado inactivo (idle). No existen mecánicas de combate o uso de armas.

## 🛠️ Tecnologías y Plan de Trabajo

*   **Motor de Desarrollo:** Godot Engine
*   **Lenguaje de Programación:** GDScript
*   **Gestión de Versiones (Git):** 
    *   Rama `main` para versiones estables.
    *   Rama `dev` para iteración y resolución de issues.
*   **Gestión de Proyectos:** GitHub Projects estructurado en formato Kanban (To Do, In Progress, Done).

### 🔗 Enlaces del Proyecto
*   **Repositorio:** [Grab the key and open the door (GitHub)](https://github.com/AntOnionPro/grab-the-key-and-open-the-door)
*   **Tablero de Tareas:** [GitHub Project Board](https://github.com/users/AntOnionPro/projects/3)
*   **Documentación:** [docs/](docs/) (GDD y guía de nomenclatura de ramas y commits)

## 🎵 Audio
*   **Música:** Pista de fondo en bucle con estilo 8-bit.
*   **Efectos de Sonido (SFX):** Sonidos específicos para el salto, recolección de llave, apertura de puerta, y pérdida de vida/reaparición (Recursos de uso libre con licencia comercial/educativa).

## 👥 Créditos

Desarrollado como proyecto para la **Universidad Tecnológica de Hermosillo, Sonora (UTH)**.

*   **Desarrollo y Programación:** Antonio de Jesus Zamorano y Jesús Efrén Campuzano.
*   **Arte y Sprites:** Recursos de uso libre y creación propia.
*   **Fecha:** Noviembre, 2026.
