# Velocity Apps & Extensions (`velocity-apps`)

Official public release repository for **Velocity Cloud Workspaces** applications and developer tooling.

This repository automatically compiles, packages, and releases production binaries and extensions directly from source code upon each version release tag (`v*`).

---

## 📦 Downloads & Releases

### 1. 🖥️ **Velocity Desktop Application**
Native, high-performance desktop application for managing cloud sandboxes, multi-monitor environments, and GPU workloads.

- 🍏 **macOS (Apple Silicon M1/M2/M3 & Intel)**: [Download `.dmg`](https://github.com/Saksham-Goel1107/velocity-apps/releases/latest)
- 🪟 **Windows 10 / 11**: [Download Executable `.exe`](https://github.com/Saksham-Goel1107/velocity-apps/releases/latest) • [Download `.msi`](https://github.com/Saksham-Goel1107/velocity-apps/releases/latest)
- 🐧 **Linux (Ubuntu / Debian / Arch)**: [Download `.AppImage`](https://github.com/Saksham-Goel1107/velocity-apps/releases/latest) • [Download `.deb`](https://github.com/Saksham-Goel1107/velocity-apps/releases/latest)

### 2. ⚡ **Velocity VS Code Extension (`.vsix`)**
Manage cloud sandboxes directly inside VS Code, view live usage & spend analytics, and connect to Velocity MCP servers.

- 🔌 **VS Code Package**: [Download `velocity-vscode.vsix`](https://github.com/Saksham-Goel1107/velocity-apps/releases/latest)

#### **How to install `.vsix` in VS Code:**
1. Open VS Code.
2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac) to open Extensions.
3. Click the `...` menu in the top right of the Extensions panel.
4. Select **Install from VSIX...** and choose your downloaded `velocity-vscode-v*.vsix` file.

---

## 🛠️ Repository Setup & CI/CD Pipeline

This repository uses GitHub Actions (`.github/workflows/release-desktop.yml`) to perform cross-platform matrix builds.

### **Required GitHub Secrets**
Set the following secret under **Repository Settings > Secrets and variables > Actions**:
- `PRIVATE_REPO_TOKEN`: A Personal Access Token (PAT) with `repo` scope to clone the source code repository.

### **Triggering a New Release**
Push a semantic tag to this repository:
```bash
git tag v1.0.0
git push origin v1.0.0
```
The automated CI pipeline will:
1. Provision Node.js v24 and pnpm v11 environments.
2. Build macOS ARM64 DMG, Windows EXE/MSI, and Linux AppImage/DEB binaries.
3. Compile and bundle the VS Code Extension (`.vsix`).
4. Publish all compiled assets to the public **GitHub Releases** page.
