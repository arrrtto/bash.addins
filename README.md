# bash.addins

Enhanced bash scripting library with modular functionality for GNU/Linux systems.

## Installation

1. Clone the repository:
```bash
git clone https://github.com/thatstraw/bash.addins.git
```

2. Create a symbolic link to your bin directory:
```bash
ln -s $(pwd)/bash.addins.sh ~/bin/bash.addins
```

3. Make it executable:
```bash
chmod +x ~/bin/bash.addins
```

4. Run setup:
```bash
bash.addins setup
```

## Features

bash.addins is now organized into several modules:

- `system`: System utilities and process management
- `text`: Text processing and regex functions
- `gui`: GUI window management
- `media`: Audio/video/image processing
- `crypto`: Cryptocurrency utilities

## Usage

```bash
# Show help
bash.addins help

# Setup bash.addins
bash.addins setup

# Update to latest version
bash.addins update

# Show version
bash.addins version

# Module-specific help
bash.addins module_name help
```

## Module Documentation

Each module has its own documentation in the `docs` directory. Check the specific module documentation for detailed usage instructions.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
