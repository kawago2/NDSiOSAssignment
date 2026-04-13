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

## API Search Strategy

To keep the implementation aligned with the Digi API docs while still covering assignment search needs:

- List search uses documented `GET /digimon` query params directly:
	- `name`
	- `exact`
	- `attribute`
	- `xAntibody`
	- `level`
	- `page`
	- `pageSize`

- `type` and `fields` are handled as enrichment filters:
	- First, fetch paged list results from `GET /digimon`.
	- Then, fetch detail data (`GET /digimon/{id}`) for those candidates.
	- Apply `type` and `fields` matching from detail metadata.

Reason:

The docs for `GET /digimon` do not expose `type` and `fields` as list query params, but the assignment requires those search dimensions. This approach keeps list requests doc-compliant and still satisfies the assignment feature scope.

Practical impact:

- For `type`/`fields` searches, one visible batch of 8 cards may require scanning multiple API pages in the background.
- Infinite scroll still displays results in batches of 8.

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
