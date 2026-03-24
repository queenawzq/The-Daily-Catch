# The Daily Catch - News Reader

**5 stories. 2 minutes. Freshly caught for your everyday.**

The Daily Catch is an iOS news briefing app that delivers personalized, AI-curated news digests. Instead of endless headlines, you get 5 stories each day with real context — what happened, why it matters, and how it affects your life.

## Features

### Quick Mode
Get the essentials fast. Each story includes a plain-language hook, context, and a "So What" section explaining why it matters to you.

### Deep Mode (Premium)
Go beyond the headlines with rich supplementary content:
- **Key Stat** — The most striking number from the story
- **Timeline** — Chronological events leading up to the story
- **Full Coverage** — How different outlets are covering it, with editorial stances
- **What to Watch** — Forward-looking analysis
- **Linked Terms** — Jargon and key terms explained inline

### Personalized Curation
Stories are tailored based on:
- **Life stage** — Student, Early Career, Building Something, Settled Career, or Figuring It Out
- **Topics** — Choose up to 3 from Money, Tech & AI, Politics, Climate, Health & Science, Culture, Global Affairs, Business & Startups, Sports, and Real Estate
- **Reading motivation** — Better conversations, better decisions, genuine curiosity, work relevance, or reducing anxiety

### Subscriptions
- **Free** — Daily 5-story briefings in Quick mode
- **Deep Catch Monthly** — $3.99/month with 7-day free trial
- **Deep Catch Yearly** — $29.99/year with 7-day free trial (save 37%)

## Tech Stack

- **SwiftUI** — Entire UI built with SwiftUI (iOS 17+)
- **StoreKit 2** — In-app subscription management
- **OpenRouter API** — AI-powered news curation using the `perplexity/sonar` model
- **MVVM architecture** — With `@Observable` macro for state management
- No external dependencies — built entirely with native iOS frameworks

## Project Structure

```
TheDailyCatch/
├── Models/                  # Data models (Story, DailyBrief, OnboardingModels, EnergyMode)
├── ViewModels/              # DailyBriefViewModel
├── Views/                   # SwiftUI views (feed, story detail, onboarding, settings, paywall)
├── Services/                # OpenRouterService, StoreManager, UserPreferencesService, BriefCacheService
├── Helpers/                 # Text cleaning utilities
├── Theme/                   # AppTheme (colors, typography)
└── Assets.xcassets/         # App icons, images
```

## Setup

1. Clone the repository
2. Create `TheDailyCatch/Secrets.plist` with your OpenRouter API key:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
     "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>OpenRouterAPIKey</key>
       <string>YOUR_API_KEY_HERE</string>
   </dict>
   </plist>
   ```
3. Open `TheDailyCatch.xcodeproj` in Xcode
4. Build and run (requires iOS 17.0+)

> `Secrets.plist` is gitignored and will not be committed.

