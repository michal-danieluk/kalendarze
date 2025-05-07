# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Start dev server: `bin/dev`
- Run all tests: `bin/rails test`
- Run single test: `bin/rails test TEST=path/to/test_file.rb:LINE_NUMBER`
- Run system tests: `bin/rails test:system`
- Run RuboCop: `bin/rubocop`
- Security scan: `bin/brakeman`

## Code Style
- Follows Rails Omakase conventions (via rubocop-rails-omakase gem)
- Uses standard Rails MVC architecture
- Uses Tailwind CSS for styling
- Uses Turbo and Stimulus for JavaScript
- File naming: snake_case for Ruby files, kebab-case for views
- Class naming: PascalCase for classes, snake_case for methods and variables
- Tests run in parallel using all available processors
- Error handling follows standard Rails patterns
- Code organization follows conventional Rails directory structure