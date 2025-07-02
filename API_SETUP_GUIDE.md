# 🔑 API Setup Guide - Smart Prospectus System

## 📋 **Quick Setup Checklist**

- [ ] **OpenAI API Key** (for AI summarization) - Optional but recommended
- [ ] **PDF Processing** - Free alternatives included
- [ ] **Translation** - Free fallback implementation included
- [ ] **Firebase** - Already configured
- [ ] **Test the app** - Works without API keys!

## 🚀 **The Good News: App Works Without API Keys!**

Your Smart Prospectus System is designed to work **immediately** without any API keys:

✅ **PDF Processing** - Uses free `pdf_text` package  
✅ **Translation** - Built-in English ↔ Swahili dictionary  
✅ **Summarization** - Local extractive summarization  
✅ **Voice Commands** - Native speech recognition  
✅ **Feedback System** - Firebase (already configured)  

## 🔧 **Where to Add API Keys**

### **1. OpenAI API Key (Optional - for better summarization)**

**File:** `lib/core/config/api_config.dart`

```dart
// Line 10: Replace this line
static const String openAiApiKey = 'your-openai-api-key-here';

// With your actual key:
static const String openAiApiKey = 'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
```

**How to get OpenAI API Key:**
1. Go to https://platform.openai.com/api-keys
2. Sign up/login to OpenAI
3. Click "Create new secret key"
4. Copy the key (starts with `sk-`)
5. Paste it in the config file above

**Cost:** ~$0.002 per 1K tokens (very cheap for summarization)

### **2. Alternative PDF Packages (Choose One)**

**Current Setup:** Using free `pdf_text` package

**If you want more features, uncomment in `pubspec.yaml`:**

```yaml
# Option 1: Keep current (FREE)
pdf_text: ^0.2.1

# Option 2: More features (FREE)
# printing: ^5.12.0

# Option 3: Syncfusion (has free tier)
# syncfusion_flutter_pdf: ^24.2.9
```

## 🎯 **Recommended Setup for Production**

### **Minimal Setup (FREE)**
```bash
# Just run the app - everything works!
flutter pub get
flutter run
```

### **Enhanced Setup (with OpenAI)**
1. Get OpenAI API key (see above)
2. Add to `lib/core/config/api_config.dart`
3. Run the app

### **Full Production Setup**
1. OpenAI API key for better summarization
2. Environment variables for security
3. Secure storage for API keys

## 🔒 **Security Best Practices**

### **For Development (Current Setup)**
```dart
// lib/core/config/api_config.dart
static const String openAiApiKey = 'sk-your-key-here'; // OK for development
```

### **For Production (Recommended)**

**Option 1: Environment Variables**
```dart
// Add flutter_dotenv to pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0

// Create .env file (add to .gitignore!)
OPENAI_API_KEY=sk-your-key-here

// Load in api_config.dart
static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
```

**Option 2: Secure Storage**
```dart
// Add flutter_secure_storage to pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0

// Store securely
final storage = FlutterSecureStorage();
await storage.write(key: 'openai_key', value: 'sk-your-key-here');

// Retrieve securely
final key = await storage.read(key: 'openai_key') ?? '';
```

## 🧪 **Testing Your Setup**

### **1. Test Without API Keys**
```bash
flutter run
# Try uploading a PDF and asking for summary
# Should work with local summarization
```

### **2. Test With OpenAI API Key**
```bash
# Add your API key to api_config.dart
flutter run
# Try summarization - should be higher quality
```

### **3. Check Configuration Status**
```dart
// In your app, check:
print(ApiConfig.getConfigStatus());
// Shows which services are configured
```

## 📱 **Platform-Specific Setup**

### **Android**
```bash
# No additional setup needed
flutter build apk
```

### **iOS**
```bash
# No additional setup needed
flutter build ios
```

## 🔍 **Troubleshooting**

### **"OpenAI API Error"**
- Check your API key is correct (starts with `sk-`)
- Verify you have credits in your OpenAI account
- App will fallback to local summarization automatically

### **"PDF Processing Failed"**
- Make sure PDF is not password protected
- Try with a smaller PDF file first
- Check file permissions

### **"Translation Not Working"**
- Built-in translation only supports English ↔ Swahili
- For more languages, add Google Translate API key
- App shows original text if translation fails

## 💰 **Cost Breakdown**

### **Free Tier (No API Keys)**
- **Cost:** $0
- **Features:** 90% of functionality
- **Limitations:** Basic summarization, limited translation

### **With OpenAI API ($5-10/month)**
- **Cost:** ~$5-10/month for typical usage
- **Features:** 100% functionality
- **Benefits:** High-quality AI summarization

### **Enterprise Setup**
- **Cost:** $20-50/month
- **Features:** All APIs, premium services
- **Benefits:** Best performance, all languages

## 🎉 **Quick Start Commands**

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app (works immediately!)
flutter run

# 3. Optional: Add OpenAI key for better summarization
# Edit lib/core/config/api_config.dart

# 4. Test with a university prospectus PDF
# Upload → Process → Ask for summary → Translate
```

## 📞 **Support**

If you encounter any issues:

1. **Check the logs** - Look for error messages in console
2. **Verify API keys** - Use `ApiConfig.getConfigStatus()`
3. **Test incrementally** - Start without API keys, then add them
4. **Check network** - Ensure internet connection for API calls

## 🎯 **Summary**

Your Smart Prospectus System is ready to use **right now** without any API keys! The OpenAI integration is optional and only enhances the summarization quality. Everything else works perfectly with the free implementations included.

**Next Steps:**
1. Run `flutter pub get`
2. Run `flutter run`
3. Upload a prospectus PDF
4. Test voice commands and summarization
5. Optionally add OpenAI key for better summaries
