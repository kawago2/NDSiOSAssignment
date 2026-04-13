# NDS iOS Assignment - Digimon Browser

Simple iOS app for browsing Digimon data from the public Digi API.

The app is built with SwiftUI and follows an MVVM-style structure with a small repository layer for networking. It was kept intentionally lightweight and readable so the flow from search to list to detail stays easy to follow.

## What it does

- Browse Digimon in a card-based list
- Open a detail page for each Digimon
- Search by name, type, attribute, level, and fields
- Load results with infinite scrolling, 8 items per page
- Show loading, empty, and error states
- Log API requests and responses during debug builds

## Tech Stack

- Swift 5
- SwiftUI
- URLSession + async/await
- MVVM
- Repository pattern

## Project Structure

- `App/` - app entry point and dependency container
- `Core/Networking/` - request building, client, logging, and error mapping
- `Core/UIComponents/` - reusable UI pieces
- `Core/Utilities/` - shared helpers
- `Features/DigimonList/` - list screen, view model, models
- `Features/DigimonDetail/` - detail screen, view model, models
- `Features/Shared/` - repository abstraction and implementation

## Running the App

1. Open `NDSiOSAssignment.xcodeproj` in Xcode.
2. Select a simulator or device.
3. Build and run the app.

## Notes

- No external dependency manager is used in this project.
- The app uses a clean, minimal layout instead of a heavy UI style.

## Submission

This project was prepared for the NDS iOS Assignment technical test.
