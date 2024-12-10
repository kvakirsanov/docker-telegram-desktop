# Telegram Desktop in Docker

## Overview
This project allows running **Telegram Desktop** inside a Docker container to enhance security and isolation. It helps protect your system from potential threats by isolating the application while maintaining full functionality.

---

## Features
- **Isolation**: Runs Telegram Desktop in a secure containerized environment.
- **Security**: Limits access to system resources.
- **Flexibility**: Supports X11/Wayland for GUI display.
- **Compatibility**: Easy integration with host system for data persistence.
- **Safe Link Handling**: Includes a hook for secure URL and file handling.

---

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/telegram-desktop-docker.git
cd telegram-desktop-docker
```

### 2. Build the Docker Image
```bash
./build.sh
```

### 3. Run Telegram Desktop
```bash
./run.sh
```

---

## About `telegram.sh`
The `telegram.sh` script manages the lifecycle of the Telegram Desktop application. It:

- **Launches Telegram Desktop**: Starts the application and tracks its process ID (PID).
- **Monitors the Application**: Continuously checks if the Telegram window remains open using `wmctrl`.
- **Graceful Shutdown**: Automatically terminates the Telegram process when the window is closed.

This script ensures a clean and controlled execution of Telegram Desktop, making it ideal for containerized environments.

## About `xdg-open-hook.sh`
The `xdg-open-hook.sh` script ensures safe handling of `xdg-open` calls made by Telegram Desktop in the container. It:
- Validates and forwards URL requests to the host system’s browser.
- Logs or rejects unsafe or unsupported file and link requests.
- Prevents unintended execution of commands, enhancing security.

This script ensures seamless integration with the host system while maintaining container isolation.

---

## Requirements
- Docker (20.x or higher).
- X11 or Wayland support for graphical output.

---

## License
This project is licensed under the [MIT License](LICENSE).

---

## Contact
- Author: Anton Kirsanov (https://github.com/kvakirsanov)