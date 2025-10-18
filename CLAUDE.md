# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[TODO: Add a brief description of what this project does and its main purpose]

## Development Setup

### Git Configuration
- User name: syrikx
- User email: syrikx@gmail.com

[TODO: Add setup instructions, dependencies, and prerequisites]

## Common Commands

### Build
[TODO: Add build command, e.g., `npm run build` or `python -m build`]

### Test
[TODO: Add test commands]
- Run all tests: [command]
- Run single test: [command]

### Lint/Format
[TODO: Add linting and formatting commands]

### Run/Serve
[TODO: Add commands to run the application]

## Architecture

This project follows the MVVM (Model-View-ViewModel) architectural pattern.

### State Management
- Use global state management
- For Flutter: Use Riverpod for state management

### Key Components
[TODO: Describe major components and how they interact]

### Data Flow
[TODO: Explain how data flows through the system]

## Important Conventions

### Development Guidelines
- Do NOT create mock data, mock pages, or mock views
- When deleting files or folders:
  - First check the number of affected files
  - Get user approval before proceeding with deletion
- Database: This project uses PostgreSQL

### Development Methodology
- Follow TDD (Test-Driven Development) approach
- Always save all test code
- Create separate MD files for explanations that users need to understand
- Document the following in MD files for future sessions:
  - Data types
  - API endpoints
  - Folder structures and document names
  - Any other information that would help continue development in the next Claude session

### Installation Documentation
- When installing modules with apt, pip, etc., record the installation commands in MD files
- For large-scale installations (e.g., PostgreSQL, Flutter, etc.):
  - Create MD files with user guidance and installation instructions
  - Include setup steps and configuration details

### Command Documentation
- Record all executed bash shell commands in separate MD files
- Record all executed SQL commands in separate MD files

[TODO: Add additional project-specific conventions, patterns, or practices that aren't obvious from reading individual files]
