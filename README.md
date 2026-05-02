# Caffeinate ☕️

**Track every sip. Know your limits.**

---

## App Tagline
*Your personal drink diary — log, track, and reflect on every cup.*

---

## Links
- **iOS Repo:** *(this repo)*
- **Backend Repo:** *(add link here if applicable)*

---

## Screenshots

Home screen showing today's caffeine summary + drink log
<img width="397" height="823" alt="Screenshot 2026-05-01 at 10 54 07 PM" src="https://github.com/user-attachments/assets/6cd8d16d-8830-4fe4-893b-49b38dc07f00" />

"Add Drink" sheet with type picker, size, and rating
<img width="399" height="825" alt="Screenshot 2026-05-01 at 10 54 15 PM" src="https://github.com/user-attachments/assets/03af3dcc-cdec-461d-86ca-08155a6f14f7" />
<img width="395" height="826" alt="Screenshot 2026-05-01 at 10 54 26 PM" src="https://github.com/user-attachments/assets/85f1b94b-d46e-45f2-99ce-1c12818b5fac" />

Report view with type breakdown bar chart
<img width="405" height="826" alt="Screenshot 2026-05-01 at 10 54 34 PM" src="https://github.com/user-attachments/assets/530a9074-3dee-4c72-a8f8-860c0f9e4b8e" />

Profile view showing all-time stats and personal records
<img width="410" height="825" alt="Screenshot 2026-05-01 at 10 54 41 PM" src="https://github.com/user-attachments/assets/08b49083-74b6-4ed2-bd11-b06fd9aabda6" />

---

## About the App

**Caffeinate** is a personal beverage tracking app for people who want to stay mindful of what they're drinking. Whether you're monitoring your caffeine intake, keeping tabs on sugar, or just want a record of that amazing pistachio cloud jasmine boba — my drinks has you covered.

### Features
- **Log any drink** — espresso, matcha, boba, energy drinks, and more, with size, temperature, price, and a personal rating
- **Daily caffeine tracker** — see today's caffeine vs. the 400 mg recommended daily limit at a glance
- **Month-by-month history** — browse past months with a simple navigator and see logs grouped by day
- **Reports** — weekly, monthly, and yearly breakdowns of your cups, caffeine, sugar, and spend with a visual type breakdown
- **Profile & stats** — all-time totals, favorite drink type, taste profile (iced vs. hot person), and personal records like your most caffeinated day

---

## Requirements Checklist

| Requirement | How it's addressed |
|---|---|
| **Persistent data** | Logs are stored as a `[Log]` array backed by `Codable` models; `NetworkManager` includes GET, POST, and DELETE endpoints for server-side persistence |
| **Custom data model** | `Log` struct with `DrinkType`, `DrinkSize`, and `DrinkTemperature` enums, all `Codable` and `Identifiable` |
| **Multiple screens / navigation** | Tab-based navigation across Home, Report, and Profile; `NewLogView` presented as a sheet; `NavigationStack` used throughout |
| **User input** | `NewLogView` collects name, date/time, drink type, size, temperature, caffeine, sugar, price, rating (heart picker), and a freeform note |
| **Dynamic UI** | Logs grouped by day on Home; Report updates in real time as period and date change; empty states handled gracefully |
| **Networking** | `NetworkManager` (async/await) wraps GET `/logs`, POST `/logs`, and DELETE `/logs/{id}` with proper error handling via `NetworkError` |
| **Date handling** | `Date` extension for creating test dates; month/week/year navigation with boundary guards (can't navigate to future periods) |
| **Computed statistics** | Caffeine totals, daily averages, sugar, spend, favorite drink type, most caffeinated day, most expensive drink, hot vs. iced preference |

---

## Notes for Graders

- The backend URL in `NetworkManager` is currently a placeholder (`api.mydrinks.example.com`) — swap in the real base URL to connect to a live server.
- Dummy data (`Log.dummyList`) is included for previews and testing without a running backend.
- The caffeine limit reference (400 mg/day) is based on FDA guidelines for healthy adults.
- The `HeartRatingView` supports tap-to-rate on a 1–5 scale with a heart icon UI.
