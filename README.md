# 🧠 MindNote AI - AI-Powered Notes & Tasks App

<p align="center">
  <strong>A comprehensive Flutter productivity application that combines intelligent note-taking and task management with powerful AI capabilities</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/AI-Groq%20LLM-7C3AED?style=for-the-badge&logo=openai&logoColor=white" alt="AI">
  <img src="https://img.shields.io/badge/SQLite-Database-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite">
</p>

---

## 📖 Overview

**MindNote AI** is a feature-rich, cross-platform productivity app built with Flutter. It combines traditional note-taking and task management with cutting-edge AI capabilities powered by Groq's LLM API. The app features modern glassmorphism UI design, voice input support, smart reminders, and intelligent features like auto-summarization, content enhancement, and natural language search.

---

## ✨ Complete Feature List

### 🏠 Dashboard (Home Screen)
| Feature | Description |
|---------|-------------|
| **Personalized Welcome** | Greeting card that welcomes the user by name |
| **AI Daily Briefing** | Generates smart productivity insights based on pending tasks and notes |
| **Quick Stats Dashboard** | Real-time overview of pending tasks, completed tasks, and total notes |
| **Recent Tasks Widget** | Quick access to pending tasks with one-tap completion toggle |
| **Quick Action Buttons** | Floating buttons for instant task and note creation |
| **Theme Toggle** | Easy switch between dark and light modes |

---

### 📋 Task Management System
| Feature | Description |
|---------|-------------|
| **Full CRUD Operations** | Create, Read, Update, and Delete tasks seamlessly |
| **Priority Levels** | Three levels (Low/Medium/High) with distinct color coding |
| **Due Date Picker** | Intuitive date picker with overdue task highlighting |
| **Subtasks Support** | Break down complex tasks into manageable subtasks |
| **AI Task Breakdown** | Automatically generates 3-5 subtasks using AI analysis |
| **Completion Toggle** | Visual checkbox feedback with smooth animations |
| **Priority Filtering** | Filter tasks by Low, Medium, or High priority |
| **AI Smart Search** | Natural language queries (e.g., "find urgent tasks about project") |
| **Bulk Delete** | Clear all completed tasks with one action |
| **Smart Sorting** | Auto-sort by priority, due date, and creation time |

---

### 📓 Notes Management System
| Feature | Description |
|---------|-------------|
| **Full CRUD Operations** | Create, Read, Update, and Delete notes with rich content |
| **AI Summarization** | Generate concise 2-3 bullet point summaries |
| **AI Enhancement** | Improve grammar, style, and clarity while preserving meaning |
| **Auto-Tagging** | AI suggests 3-5 relevant tags based on note content |
| **Related Notes Discovery** | AI finds semantically related notes from your collection |
| **Voice-to-Text Input** | Hands-free note creation using speech recognition |
| **Voice Note Formatting** | AI cleans up transcriptions (removes filler words, adds punctuation) |
| **AI Smart Search** | Natural language search across all notes |
| **Tag Management** | View, filter, and search notes by tags |
| **Glass Card UI** | Modern glassmorphism design with blur effects |

---

### ⏰ Smart Reminder System
| Feature | Description |
|---------|-------------|
| **AI Date Parsing** | Automatically extracts dates/times from note content |
| **Scheduled Notifications** | Set reminders based on detected dates |
| **Local Push Notifications** | Timely reminders with high-priority alerts |
| **Timezone Support** | Proper handling of local timezone for accurate notifications |

---

### 👤 User Profile
| Feature | Description |
|---------|-------------|
| **Editable Profile** | Customize name and email |
| **Activity Statistics** | View total tasks, completed tasks, and notes count |
| **Data Management** | Clear all data option for fresh start |

---

### ⚙️ Settings & Preferences
| Feature | Description |
|---------|-------------|
| **Dark/Light Mode** | Dynamic theme switching with Material 3 |
| **Language Selection** | English, Spanish, French, German support |
| **Push Notification Toggle** | Enable/disable notification alerts |
| **Cache Management** | Clear cached data |
| **Privacy Policy** | Access privacy information |
| **Terms of Service** | View terms and conditions |
| **Danger Zone** | Full data reset option |

---

## 🛠️ Technology Stack

### Core Framework
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.0+ | Cross-platform UI framework |
| **Dart** | 3.0+ | Programming language |
| **Material 3** | Latest | Modern design system |

### State Management
| Package | Purpose |
|---------|---------|
| **Provider** | Reactive state management with ChangeNotifier pattern |

### Data Storage
| Package | Purpose |
|---------|---------|
| **sqflite** | Local SQLite database for persistent data |
| **shared_preferences** | Lightweight key-value storage for settings |
| **path_provider** | Platform-specific storage paths |

### AI & LLM Integration
| Package | Purpose |
|---------|---------|
| **http** | HTTP client for Groq API calls |
| **Groq API** | LLM-powered AI features (Mixtral-8x7b-32768) |

### Voice & Audio
| Package | Purpose |
|---------|---------|
| **speech_to_text** | Speech recognition for voice notes |
| **permission_handler** | Microphone permission management |

### Notifications
| Package | Purpose |
|---------|---------|
| **flutter_local_notifications** | Local push notification scheduling |
| **timezone** | Accurate timezone handling for reminders |

### UI Enhancements
| Package | Purpose |
|---------|---------|
| **glass_kit** | Glassmorphism UI effects |
| **intl** | Internationalization and date formatting |

### Development
| Package | Purpose |
|---------|---------|
| **flutter_launcher_icons** | App icon generation for all platforms |
| **flutter_lints** | Code quality and best practices |

---

## 📁 Project Architecture

```
lib/
├── main.dart                       # App entry point, theme config, providers setup
│
├── models/                         # Data Models (Plain Dart Classes)
│   ├── note.dart                   # Note model with tags, aiSummary, isAIEnhanced
│   ├── task.dart                   # Task model with priority, subtasks, dueDate
│   └── user_profile.dart           # User profile with preferences map
│
├── providers/                      # State Management (ChangeNotifier Pattern)
│   ├── note_provider.dart          # Notes CRUD, search, AI features (208 lines)
│   ├── task_provider.dart          # Tasks CRUD, filtering, AI features (190 lines)
│   └── user_provider.dart          # User prefs, dark mode, language (43 lines)
│
├── screens/                        # UI Screens
│   ├── main_navigation.dart        # Bottom navigation controller
│   ├── home_screen.dart            # Dashboard with stats & quick actions
│   ├── notes_screen.dart           # Notes list with search & glass cards
│   ├── tasks_screen.dart           # Tasks list with priority filters
│   ├── profile_screen.dart         # User profile & activity stats
│   ├── settings_screen.dart        # App settings & preferences
│   ├── add_edit_note_screen.dart   # Note editor with AI tools (21KB)
│   └── add_edit_task_screen.dart   # Task editor with AI breakdown (15KB)
│
├── services/                       # Business Logic & External APIs
│   ├── ai_assistant_service.dart   # All AI methods (summarize, enhance, tags, etc.)
│   ├── groq_service.dart           # Groq LLM API integration
│   ├── database_service.dart       # SQLite CRUD operations (singleton)
│   ├── notification_service.dart   # Local notification scheduling
│   └── voice_service.dart          # Speech-to-text functionality
│
├── utils/                          # Utilities & Constants
│   ├── constants.dart              # Colors, spacing, animation durations
│   └── helpers.dart                # Date formatting, priority colors, dialogs
│
└── widgets/                        # Reusable UI Components
    └── glass_card.dart             # Glassmorphism card with blur effect
```

---

## 🤖 AI Features Deep Dive

MindNote AI leverages **Groq's LLM API** with the **Mixtral-8x7b-32768** model for intelligent features:

| Feature | Method | Description |
|---------|--------|-------------|
| **Note Summarization** | `summarizeNote()` | Creates 2-3 bullet point summaries |
| **Note Enhancement** | `enhanceNote()` | Improves grammar, style, clarity |
| **Voice Formatting** | `formatVoiceNote()` | Cleans transcriptions, removes filler words |
| **Auto-Tagging** | `suggestTags()` | Suggests 3-5 relevant single-word tags |
| **Task Breakdown** | `breakdownTask()` | Splits complex tasks into 3-5 subtasks |
| **Daily Briefing** | `analyzeDailyBriefing()` | Personalized productivity insights |
| **Smart Search** | `analyzeSearchQuery()` | Parses natural language into structured query |
| **Reminder Detection** | `parseReminderDateTime()` | Extracts dates/times from text |
| **Related Notes** | `findRelatedNotes()` | Finds semantically similar notes |

---

## 🗃️ Database Schema

### Notes Table
```sql
CREATE TABLE notes(
    id TEXT PRIMARY KEY,
    title TEXT,
    content TEXT,
    createdAt TEXT,
    updatedAt TEXT,
    tags TEXT,           -- JSON encoded array
    aiSummary TEXT,
    isAIEnhanced INTEGER -- 0 or 1
)
```

### Tasks Table
```sql
CREATE TABLE tasks(
    id TEXT PRIMARY KEY,
    title TEXT,
    description TEXT,
    isCompleted INTEGER,  -- 0 or 1
    createdAt TEXT,
    dueDate TEXT,
    priority TEXT,        -- 'low', 'medium', 'high'
    subtasks TEXT,        -- JSON encoded array
    aiSuggestion TEXT
)
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** 3.0 or higher
- **Dart SDK** 3.0 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Groq API Key** (free tier available at [groq.com](https://groq.com))

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd Notes
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**
   
   Create a `.env` file in the project root:
   ```env
   GROQ_API_KEY=your_groq_api_key_here
   GROQ_MODEL=mixtral-8x7b-32768
   ```
   
   > 📝 **Note**: Get your free API key from [console.groq.com](https://console.groq.com)

4. **Generate App Icons** (Optional)
   ```bash
   flutter pub run flutter_launcher_icons
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Microphone permission configured in `AndroidManifest.xml`

#### iOS
- Add microphone usage description in `Info.plist`
- Enable background modes for notifications

---

## 📱 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| ✅ Android | Supported | Full feature support |
| ✅ iOS | Supported | Full feature support |
| ✅ Web | Supported | Limited voice input |
| ✅ Windows | Supported | Desktop optimized |
| ✅ macOS | Supported | Desktop optimized |
| ✅ Linux | Supported | Desktop optimized |

---

## 🎨 Design System

### Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#2196F3` | Main accent color |
| Secondary | `#03DAC6` | Secondary actions |
| Accent | `#FF4081` | Highlights |
| Low Priority | `#4CAF50` | Green |
| Medium Priority | `#FF9800` | Orange |
| High Priority | `#F44336` | Red |

### Typography & Spacing
- **Border Radius**: 8px (small), 12px (medium), 16px (large)
- **Padding**: 8px, 16px, 24px, 32px
- **Animations**: 200ms, 300ms, 500ms durations

---

## 🔒 Privacy & Security

- All data stored locally on device using SQLite
- No user data uploaded to servers (except AI prompts to Groq)
- API keys stored in `.env` file (not committed to git)
- Microphone access only when explicitly activated

---

## 📄 License

This project is created for **educational/learning purposes** as part of the Mobile Application Development course.

---

## 👨‍💻 Author

**Awais Hussain**  
7th Semester - Mobile Application Development

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Groq](https://groq.com) for the fast LLM API
- [Material Design 3](https://m3.material.io/) for design guidelines
