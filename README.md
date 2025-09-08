<div align="center">

# 🤖 AI Tespit Sistemi

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Google AI](https://img.shields.io/badge/Google_AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)
[![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org/)

**Metin, dosya ve resimlerde AI tarafından yazılıp yazılmadığını tespit eden akıllı sistem**

[🚀 Demo](#-demo) • [📱 Özellikler](#-özellikler) • [🛠️ Kurulum](#️-kurulum) • [📖 Kullanım](#-kullanım) • [🤝 Katkıda Bulunma](#-katkıda-bulunma)

</div>

---

## 🎯 Proje Hakkında

Bu proje, **Google Gemini AI** teknolojisini kullanarak metin, dosya ve resimlerde yapay zeka tarafından üretilmiş içerikleri tespit eden kapsamlı bir sistemdir. Flutter ile geliştirilmiş modern mobil uygulama ve Node.js backend servisi ile güçlendirilmiştir.

### 🏆 Temel Özellikler

- 🔍 **Çoklu Format Desteği**: Metin, PDF, DOC, DOCX, TXT ve resim analizi
- 🎨 **Modern UI/UX**: Material Design 3 ile tasarlanmış kullanıcı dostu arayüz
- 🔐 **Güvenli Sistem**: Bcrypt ile şifreleme ve JWT tabanlı kimlik doğrulama
- 📊 **Çoklu Abonelik**: Temel, Premium ve Sınırsız plan seçenekleri
- 🚀 **Cross-Platform**: iOS, Android ve Web desteği
- ⚡ **Gerçek Zamanlı**: Hızlı analiz ve anında sonuçlar

## 🚀 Demo

<div align="center">

### 📱 Uygulama Ekran Görüntüleri

| Giriş Ekranı | Ana Ekran | Analiz Sonucu |
|:---:|:---:|:---:|
| ![Login](https://via.placeholder.com/200x400/667eea/ffffff?text=Login+Screen) | ![Home](https://via.placeholder.com/200x400/764ba2/ffffff?text=Home+Screen) | ![Result](https://via.placeholder.com/200x400/4285f4/ffffff?text=Analysis+Result) |

</div>

## 📱 Özellikler

### 🔍 Analiz Türleri

| Özellik | Açıklama | Desteklenen Formatlar |
|---------|----------|----------------------|
| 📝 **Metin Analizi** | Yazılı metinlerde AI tespiti | Plain text, Markdown |
| 📄 **Dosya Analizi** | Belge dosyalarında AI tespiti | PDF, DOC, DOCX, TXT |
| 🖼️ **Resim Analizi** | Görsel içerikte AI tespiti | JPG, PNG, GIF |

### 🎯 Abonelik Planları

| Plan | Fiyat | Kelime Limiti | Dosya Limiti | Resim Analizi |
|------|-------|---------------|--------------|---------------|
| 🆓 **Temel** | Ücretsiz | 1,000/gün | 5/gün | ❌ |
| ⭐ **Premium** | ₺29.99/ay | 10,000/gün | 50/gün | ✅ |
| 💎 **Sınırsız** | ₺99.99/ay | Sınırsız | Sınırsız | ✅ |

## 🛠️ Teknoloji Stack

### 🎨 Frontend
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material_Design-757575?style=flat-square&logo=material-design&logoColor=white)

### ⚙️ Backend
![Node.js](https://img.shields.io/badge/Node.js-43853D?style=flat-square&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-000000?style=flat-square&logo=express&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=flat-square&logo=sqlite&logoColor=white)

### 🤖 AI & ML
![Google AI](https://img.shields.io/badge/Google_AI-4285F4?style=flat-square&logo=google&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-FF6B6B?style=flat-square&logo=google&logoColor=white)
![Tesseract](https://img.shields.io/badge/Tesseract-FF6B6B?style=flat-square&logo=tesseract&logoColor=white)

## 🚀 Hızlı Başlangıç

### 📋 Gereksinimler

- ![Node.js](https://img.shields.io/badge/Node.js-v14+-green?style=flat-square) Node.js (v14 veya üzeri)
- ![Flutter](https://img.shields.io/badge/Flutter-v3.0+-blue?style=flat-square) Flutter SDK
- ![Google AI](https://img.shields.io/badge/Google_AI-API_Key-orange?style=flat-square) Google Gemini API anahtarı

### 🔧 Backend Kurulumu

```bash
# 1️⃣ Projeyi klonlayın
git clone https://github.com/username/ai-detection-system.git
cd ai-detection-system

# 2️⃣ Bağımlılıkları yükleyin
npm install

# 3️⃣ Environment dosyasını oluşturun
cp .env.example .env

# 4️⃣ API anahtarınızı ekleyin
echo "GEMINI_API_KEY=your_api_key_here" >> .env

# 5️⃣ Sunucuyu başlatın
npm start
```

### 📱 Flutter Uygulaması

```bash
# 1️⃣ Flutter klasörüne gidin
cd ai_detection_app

# 2️⃣ Bağımlılıkları yükleyin
flutter pub get

# 3️⃣ Uygulamayı çalıştırın
flutter run
```

## 🔑 API Anahtarı Alma

<div align="center">

### 🎯 Google Gemini API Anahtarı

[![Google AI Studio](https://img.shields.io/badge/Google_AI_Studio-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://makersuite.google.com/app/apikey)

</div>

### 📝 Adım Adım Kurulum

1. **🔗 [Google AI Studio](https://makersuite.google.com/app/apikey)** adresine gidin
2. **🔐 Google hesabınızla** giriş yapın
3. **➕ "Create API Key"** butonuna tıklayın
4. **📋 API anahtarınızı** kopyalayın
5. **⚙️ `.env` dosyasına** ekleyin

```env
GEMINI_API_KEY=your_actual_api_key_here
```

## 👥 Test Kullanıcıları

<div align="center">

### 🧪 Hazır Test Hesapları

| 👤 Kullanıcı | 🔑 Şifre | 🎯 Plan | ✨ Özellikler |
|:---:|:---:|:---:|:---:|
| `temel` | `123` | 🆓 Temel | Sadece metin analizi |
| `premium` | `123` | ⭐ Premium | Tüm özellikler |
| `sınırsız` | `123` | 💎 Sınırsız | Sınırsız kullanım |

</div>

## 📖 Kullanım Kılavuzu

### 🚀 Başlangıç

1. **📱 Uygulamayı açın**
2. **🔐 Test kullanıcılarından biriyle giriş yapın**
3. **📊 Analiz türünü seçin**

### 🔍 Analiz Türleri

#### 📝 Metin Analizi
```
1. "Metin Analizi" sekmesine gidin
2. Analiz etmek istediğiniz metni yazın
3. "Analiz Et" butonuna tıklayın
4. Sonuçları görüntüleyin
```

#### 📄 Dosya Analizi
```
1. "Dosya Analizi" sekmesine gidin
2. "Dosya Seç" butonuna tıklayın
3. PDF, DOC, DOCX veya TXT dosyası seçin
4. "Analiz Et" butonuna tıklayın
```

#### 🖼️ Resim Analizi
```
1. "Resim Analizi" sekmesine gidin
2. "Kamera" veya "Galeri" seçin
3. Resmi çekin veya seçin
4. "Analiz Et" butonuna tıklayın
```

## 🔒 Güvenlik

<div align="center">

### 🛡️ Güvenlik Önlemleri

| Özellik | Açıklama | Durum |
|---------|----------|-------|
| 🔐 **API Key Protection** | Environment variables ile korunur | ✅ |
| 🚫 **Git Security** | `.env` dosyası Git'e dahil edilmez | ✅ |
| 🔒 **Password Hashing** | Bcrypt ile şifreleme | ✅ |
| 🌐 **CORS Policy** | Cross-origin güvenlik | ✅ |
| 🔑 **JWT Authentication** | Token tabanlı kimlik doğrulama | ✅ |

</div>

## 📁 Proje Yapısı

```
📦 ai-detection-system/
├── 📱 ai_detection_app/          # Flutter uygulaması
│   ├── 📁 lib/
│   │   ├── 📁 models/           # Veri modelleri
│   │   ├── 📁 providers/        # State management
│   │   ├── 📁 screens/          # UI ekranları
│   │   ├── 📁 services/         # API servisleri
│   │   └── 📁 widgets/          # Özel widget'lar
│   └── 📄 pubspec.yaml
├── ⚙️ server.js                 # Backend sunucu
├── 🗄️ database.js              # Veritabanı işlemleri
├── 🔧 .env.example             # Environment variables örneği
├── 🚫 .gitignore               # Git ignore kuralları
├── 📋 package.json             # Node.js bağımlılıkları
└── 📖 README.md                # Bu dosya
```

## 🤝 Katkıda Bulunma

<div align="center">

### 🚀 Projeye Katkı Sağlayın!

[![Contributors Welcome](https://img.shields.io/badge/Contributors-Welcome-brightgreen?style=for-the-badge)](https://github.com/username/ai-detection-system)

</div>

### 📝 Katkı Süreci

1. **🍴 Fork yapın** - Projeyi kendi hesabınıza kopyalayın
2. **🌿 Branch oluşturun** - `git checkout -b feature/amazing-feature`
3. **💾 Commit edin** - `git commit -m 'Add amazing feature'`
4. **📤 Push edin** - `git push origin feature/amazing-feature`
5. **🔄 Pull Request** - Değişikliklerinizi gözden geçirmek için PR oluşturun

### 🎯 Katkı Alanları

- 🐛 **Bug Fixes** - Hata düzeltmeleri
- ✨ **New Features** - Yeni özellikler
- 📚 **Documentation** - Dokümantasyon iyileştirmeleri
- 🎨 **UI/UX** - Arayüz geliştirmeleri
- ⚡ **Performance** - Performans optimizasyonları

## 📊 Proje İstatistikleri

<div align="center">

![GitHub stars](https://img.shields.io/github/stars/username/ai-detection-system?style=social)
![GitHub forks](https://img.shields.io/github/forks/username/ai-detection-system?style=social)
![GitHub issues](https://img.shields.io/github/issues/username/ai-detection-system)
![GitHub pull requests](https://img.shields.io/github/issues-pr/username/ai-detection-system)

</div>

## 📄 Lisans

<div align="center">

### 📜 MIT License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

</div>

## ⚠️ Önemli Notlar

<div align="center">

### 🚨 Güvenlik Uyarıları

| ⚠️ Uyarı | 📝 Açıklama |
|----------|-------------|
| 🔑 **API Key** | API anahtarınızı asla public repository'lerde paylaşmayın |
| 🛡️ **Production** | Production ortamında güvenlik önlemlerini artırın |
| 🚦 **Rate Limiting** | Rate limiting ve authentication ekleyin |
| 💾 **Backup** | Veritabanı yedekleme stratejisi oluşturun |

</div>

---

<div align="center">

### 🌟 Projeyi Beğendiyseniz Yıldız Vermeyi Unutmayın!

[![GitHub stars](https://img.shields.io/github/stars/username/ai-detection-system?style=social&label=Star)](https://github.com/username/ai-detection-system)

**Geliştirici:** [@username](https://github.com/username) • **Email:** your.email@example.com

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/username)
[![Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/username)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/username)

</div>