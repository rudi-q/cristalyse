# Contributing to Cristalyse 🔮

Thanks for your interest in making Cristalyse better! We're building the grammar of graphics library that Flutter developers deserve, and we'd love your help.

## 🚀 Quick Start for Contributors

### Prerequisites
- Flutter 1.17.0+ (we support a wide range!)
- Dart 3.7.0+
- Git
- A code editor (VS Code, Android Studio, IntelliJ)

### Get the Code
```bash
git clone https://github.com/rudi-q/cristalyse.git
cd cristalyse
flutter pub get
```

### Run the Example
```bash
cd example
flutter run
```

You should see animated charts demonstrating current features!

## 🎯 How You Can Help

### 🐛 Found a Bug?
1. **Search existing issues** first - might already be reported
2. **Create a new issue** with:
    - Clear title describing the problem
    - Steps to reproduce
    - Expected vs actual behavior
    - Flutter/Dart versions
    - Code sample if possible

### 💡 Have a Feature Idea?
1. **Check our roadmap** in the README - might already be planned
2. **Open a discussion** before diving into code
3. **Keep it focused** - smaller features are easier to review

### 📝 Improve Documentation?
- Fix typos, improve examples, add clarifications
- Documentation lives in `/doc` and code comments
- README improvements are always welcome

## 🔧 Development Workflow

### 1. Pick an Issue
- Look for `good first issue` labels for newcomers
- Comment on the issue to claim it
- Ask questions if anything is unclear

### 2. Create a Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 3. Make Your Changes
- **Keep it focused** - one feature/fix per PR
- **Follow our coding style** (see below)
- **Add tests** for new features
- **Update examples** if adding new APIs

### 4. Test Everything
```bash
# Run tests
flutter test

# Test the example app
cd example && flutter run

# Test on multiple platforms if possible
flutter run -d chrome    # Web
flutter run -d macos     # Desktop (if available)
```

### 5. Submit a Pull Request
- **Clear title** explaining what you changed
- **Link to issue** if applicable
- **Describe your changes** and why you made them
- **Screenshots/GIFs** for visual changes are gold! ✨

## 📋 Coding Guidelines

### Code Style
We follow standard Dart conventions:
```bash
flutter analyze
dart format .
```

### Architecture Principles
1. **Grammar of Graphics** - Keep the API consistent with ggplot2 patterns
2. **Performance First** - 60fps is non-negotiable
3. **Cross-Platform** - Code should work identically everywhere
4. **Progressive Enhancement** - New features shouldn't break existing code

### File Organization
```
lib/
├── src/
│   ├── core/           # Core classes (Chart, Geometry, Scale)
│   ├── geometries/     # Specific geometry implementations  
│   ├── scales/         # Scale implementations
│   ├── themes/         # Theme system
│   └── widgets/        # Flutter widgets
├── cristalyse.dart     # Main export file
example/
├── lib/                # Example applications
test/
├── *_test.dart         # Unit tests
```

### Adding New Geometries

When adding a new geometry (like `geom_bar`):

1. **Create the geometry class** in `lib/src/core/geometry.dart`:
```dart
class BarGeometry extends Geometry {
  final double width;
  final BarOrientation orientation;
  
  BarGeometry({this.width = 0.8, this.orientation = BarOrientation.vertical});
}
```

2. **Add the API method** in `lib/src/core/chart.dart`:
```dart
CristalyseChart geomBar({double? width, BarOrientation? orientation}) {
  _geometries.add(BarGeometry(width: width ?? 0.8, orientation: orientation ?? BarOrientation.vertical));
  return this;
}
```

3. **Implement rendering** in the chart painter
4. **Add tests** in `test/`
5. **Update example** in `example/lib/`

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
cd example
flutter test integration_test/
```

### Manual Testing Checklist
- [ ] Works on iOS simulator
- [ ] Works on Android emulator
- [ ] Works in Chrome (web)
- [ ] Works on desktop (if available)
- [ ] Animations are smooth (60fps)
- [ ] No console errors or warnings
- [ ] Memory usage stays reasonable

## 📦 Release Process

(For maintainers)

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with new features/fixes
3. Run full test suite
4. Tag release: `git tag v0.x.x`
5. Publish: `flutter pub publish`

## 🏗 Current Architecture

### Core Classes
- **CristalyseChart** - Main API entry point, fluent interface
- **Geometry** - Base class for visual elements (points, lines, bars)
- **Scale** - Data transformation (linear, ordinal, color, size)
- **ChartTheme** - Visual styling system

### Rendering Pipeline
```
Data → Mapping → Scaling → Geometry → Canvas → Animation
```

### Animation System
- Uses Flutter's `AnimationController` for smooth 60fps
- Supports staggered animations for multiple elements
- Progressive rendering for line charts
- Validates all values to prevent crashes

## 🎨 Design Philosophy

1. **Developer Experience First** - API should feel natural to Flutter developers
2. **Grammar of Graphics** - Layered approach like ggplot2, not rigid chart types
3. **Performance Matters** - Native rendering, not web-based solutions
4. **Progressive Disclosure** - Simple things simple, complex things possible

## ❓ Questions?

- **General discussion**: [GitHub Discussions](https://github.com/rudi-q/cristalyse/discussions)
- **Bug reports**: [GitHub Issues](https://github.com/rudi-q/cristalyse/issues)
- **Quick questions**: Comment on relevant issues

## 🙏 Recognition

Contributors get:
- Credit in `CHANGELOG.md`
- Mention in release notes for major contributions
- Eternal gratitude!

---

**Ready to contribute?** Pick an issue and let's build something amazing together! 🚀