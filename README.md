# AI Tespit Sistemi

Bu proje, metin, dosya ve resimlerde AI tarafından yazılıp yazılmadığını tespit eden bir Flutter uygulaması ve Node.js backend servisidir.

## 🚀 Özellikler

- **Metin Analizi**: Yazılı metinlerde AI tespiti
- **Dosya Analizi**: PDF, DOC, DOCX, TXT dosyalarında AI tespiti
- **Resim Analizi**: Resimlerde AI tespiti
- **Çoklu Abonelik Seviyeleri**: Temel, Premium, Sınırsız planlar
- **Kullanıcı Yönetimi**: Giriş/çıkış sistemi
- **Geri Bildirim Sistemi**: Analiz sonuçları için geri bildirim

## 🛠️ Kurulum

### Gereksinimler
- Node.js (v14 veya üzeri)
- Flutter SDK
- Google Gemini API anahtarı

### Backend Kurulumu

1. Projeyi klonlayın:
```bash
git clone <repository-url>
cd tespitai
```

2. Bağımlılıkları yükleyin:
```bash
npm install
```

3. Environment variables dosyasını oluşturun:
```bash
cp .env.example .env
```

4. `.env` dosyasını düzenleyin ve API anahtarınızı ekleyin:
```env
GEMINI_API_KEY=your_gemini_api_key_here
DB_PATH=./ai_detection.db
PORT=3000
NODE_ENV=development
```

5. Sunucuyu başlatın:
```bash
npm start
# veya development için
npm run dev
```

### Flutter Uygulaması Kurulumu

1. Flutter klasörüne gidin:
```bash
cd ai_detection_app
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

## 🔑 API Anahtarı Alma

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. Google hesabınızla giriş yapın
3. "Create API Key" butonuna tıklayın
4. API anahtarınızı kopyalayın
5. `.env` dosyasına ekleyin

## 👥 Test Kullanıcıları

Uygulamada test için hazır kullanıcılar bulunmaktadır:

| Kullanıcı Adı | Şifre | Plan | Özellikler |
|---------------|-------|------|------------|
| `temel` | `123` | Temel | Sadece metin analizi |
| `premium` | `123` | Premium | Tüm özellikler |
| `sınırsız` | `123` | Sınırsız | Sınırsız kullanım |

## 📱 Kullanım

1. Uygulamayı açın
2. Test kullanıcılarından biriyle giriş yapın
3. Analiz etmek istediğiniz içeriği seçin:
   - **Metin**: Doğrudan yazın
   - **Dosya**: PDF, DOC, DOCX, TXT yükleyin
   - **Resim**: Kamera veya galeriden seçin
4. "Analiz Et" butonuna tıklayın
5. Sonuçları görüntüleyin

## 🔒 Güvenlik

- API anahtarları environment variables ile korunur
- `.env` dosyası Git'e dahil edilmez
- Kullanıcı şifreleri bcrypt ile hash'lenir
- CORS politikaları uygulanır

## 📁 Proje Yapısı

```
tespitai/
├── ai_detection_app/          # Flutter uygulaması
│   ├── lib/
│   │   ├── models/           # Veri modelleri
│   │   ├── providers/        # State management
│   │   ├── screens/          # UI ekranları
│   │   ├── services/         # API servisleri
│   │   └── widgets/          # Özel widget'lar
│   └── pubspec.yaml
├── server.js                 # Backend sunucu
├── database.js              # Veritabanı işlemleri
├── .env.example             # Environment variables örneği
├── .gitignore               # Git ignore kuralları
└── README.md                # Bu dosya
```

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## ⚠️ Önemli Notlar

- API anahtarınızı asla public repository'lerde paylaşmayın
- Production ortamında güvenlik önlemlerini artırın
- Rate limiting ve authentication ekleyin
- Veritabanı yedekleme stratejisi oluşturun