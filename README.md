# VIA - Voice Interactive Assistant

A Flutter-based voice-controlled document management and accessibility application that helps users interact with documents through voice commands and provides comprehensive accessibility features.

## 🎯 Features

### 📄 Document Management
- **PDF Upload & Processing**: Upload and process PDF documents with automatic content extraction
- **Voice-Controlled Navigation**: Navigate through documents using voice commands
- **Document Search**: Search through your document library with voice or text
- **Multi-language Support**: Support for multiple languages with localized content

### 🎤 Voice Commands
- **Speech-to-Text**: Convert spoken words to text for document interaction
- **Text-to-Speech**: Read document content aloud with customizable voice settings
- **Voice Navigation**: Navigate the app using voice commands
- **Command Recognition**: Intelligent voice command processing and execution

### ♿ Accessibility Features
- **Screen Reader Support**: Full compatibility with screen readers
- **Voice Feedback**: Audio feedback for all user interactions
- **High Contrast Mode**: Enhanced visual accessibility options
- **Font Size Adjustment**: Customizable text sizing for better readability
- **Keyboard Navigation**: Complete keyboard navigation support

### 🌐 Internationalization
- **Multi-language UI**: Support for multiple languages
- **Localized Content**: Fully localized user interface and voice prompts
- **Language Switching**: Easy language switching with voice commands

## 🏗️ Architecture

This app follows **Clean Architecture** principles with:

- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources and repositories
- **Presentation Layer**: UI components and state management

### 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth, Firestore) + Supabase (Storage)
- **Voice Processing**:
  - `speech_to_text` for speech recognition
  - `flutter_tts` for text-to-speech
- **PDF Processing**: `pdfx` for PDF handling
- **Internationalization**: Flutter's built-in i18n support

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase project setup
- Supabase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd via
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure Supabase**
   - Create a Supabase project
   - Update `lib/config/supabase_config.dart` with your Supabase credentials
   - Set up storage buckets (see Storage Setup section)

5. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Storage Setup

The app uses Supabase for file storage. You need to create the following buckets in your Supabase dashboard:

### Required Buckets

1. **images**
   - Public: Yes
   - Size limit: 10MB
   - MIME types: `image/*`

2. **videos**
   - Public: Yes
   - Size limit: 50MB
   - MIME types: `video/*`

3. **documents**
   - Public: Yes
   - Size limit: 50MB
   - MIME types: `application/pdf`, `application/msword`, `text/*`

### Storage Policies

Create RLS (Row Level Security) policies for each bucket:

```sql
-- Public read access for images
CREATE POLICY "Public read access for images" ON storage.objects
FOR SELECT USING (bucket_id = 'images');

-- Public read access for videos
CREATE POLICY "Public read access for videos" ON storage.objects
FOR SELECT USING (bucket_id = 'videos');

-- Public read access for documents
CREATE POLICY "Public read access for documents" ON storage.objects
FOR SELECT USING (bucket_id = 'documents');

-- Authenticated users can upload to their own folders
CREATE POLICY "Users can upload to own folder" ON storage.objects
FOR INSERT WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);
```

## 🎮 Usage

### Voice Commands

The app supports various voice commands:

- **"Upload document"** - Start document upload process
- **"Read document"** - Read the current document aloud
- **"Search for [query]"** - Search through documents
- **"Go to settings"** - Navigate to settings
- **"Change language to [language]"** - Switch interface language
- **"Help"** - Get voice command help

### Document Management

1. **Upload Documents**: Use the upload button or voice command to add PDF documents
2. **Browse Documents**: View your document library with search and filter options
3. **Voice Navigation**: Use voice commands to navigate through document content
4. **Accessibility**: All features are accessible via screen readers and keyboard navigation

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Customization

- **Voice Settings**: Adjust TTS speed, pitch, and voice in Settings
- **Accessibility**: Configure contrast, font size, and screen reader preferences
- **Language**: Choose from supported languages in the language selector

## 🧪 Testing

Run tests with:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

## 📱 Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Limited voice features)
- ✅ **macOS** (Desktop support)
- ✅ **Windows** (Desktop support)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

- Create an issue in the GitHub repository
- Check the documentation in the `/docs` folder
- Review the voice command help within the app

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase and Supabase for backend services
- The accessibility community for guidance and feedback
- Contributors and testers who helped improve the app
