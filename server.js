require('dotenv').config(); /// environment variables yükleniyor
const express = require('express'); /// express kütüphanesi import ediliyor
const multer = require('multer');
const { GoogleGenerativeAI } = require('@google/generative-ai'); /// GoogleGenerativeAI kütüphanesi import ediliyor
const cors = require('cors'); /// cors kütüphanesi import ediliyor
const fs = require('fs'); /// fs kütüphanesi import ediliyor
const bcrypt = require('bcrypt'); /// bcrypt kütüphanesi import ediliyor
const sharp = require('sharp'); /// resim işleme için sharp
const Tesseract = require('tesseract.js'); /// OCR için tesseract
const Database = require('./database'); /// veritabanı sınıfı import ediliyor

const app = express(); /// express kütüphanesi kullanılarak bir uygulama oluşturuluyor
const PORT = 3000;

// Veritabanı bağlantısı
const db = new Database();

// Tek kullanıcı oluştur (sadece ilk çalıştırmada)
async function initializeUser() {
    try {
        const username = 'user';
        const password = 'user123';
        const name = 'Kullanıcı';
        const role = 'user';
        
        const existingUser = await db.getUserByUsername(username);
        if (!existingUser) {
            const hashedPassword = await bcrypt.hash(password, 10);
            await db.createUser(username, hashedPassword, name, role);
            console.log(`✅ Kullanıcı oluşturuldu: ${username}`);
        }
    } catch (error) {
        console.error('Kullanıcı oluşturma hatası:', error);
    }
}

// Kullanıcıyı başlat
setTimeout(initializeUser, 1000);

// Gemini API anahtarı
const GEMINI_API_KEY = process.env.GEMINI_API_KEY; /// Gemini API anahtarı environment variable'dan alınıyor

// Middleware
app.use(cors()); /// cors kütüphanesi kullanılarak CORS politikaları uygulanıyor
app.use(express.json()); /// express kütüphanesi kullanılarak JSON verileri işleniyor
app.use(express.static('public'));

// Multer konfigürasyonu
const upload = multer({ dest: 'uploads/' }); /// multer kütüphanesi kullanılarak dosya yükleme işlemi yapılıyor

// Gelişmiş AI analizi - geçmiş verilerle öğrenme
async function analyzeHomework(content, fileName, userId = 'anonymous') {
    try {
        if (!GEMINI_API_KEY || GEMINI_API_KEY === 'YOUR_GEMINI_API_KEY_HERE') { /// Gemini API anahtarı kontrol ediliyor
            return {
                analysis: `🤖 DEMO ANALİZ\n\n📝 ${fileName} dosyası analiz edildi.\n\n⚠️ Gemini API anahtarı gerekli!\n\n🔧 Ayarlama:\n1. https://makersuite.google.com/app/apikey adresinden API anahtarı alın\n2. server.js dosyasında GEMINI_API_KEY değişkenini güncelleyin\n3. Sistemi yeniden başlatın`,
                aiProbability: 50,
                aiDetected: false,
                confidenceScore: 0
            };
        }

        // Geçmiş verilerden öğrenme verilerini al
        const learningData = await db.getLearningData(100);
        const accuracyStats = await db.getAccuracyRate(30);
        
        // Öğrenme verilerinden prompt iyileştirmesi
        let learningContext = '';
        if (learningData.length > 0) {
            learningContext = `\n\nÖNCEKİ ANALİZLERDEN ÖĞRENME:\n`;
            learningContext += `- Toplam analiz sayısı: ${learningData.length}\n`;
            learningContext += `- Son 30 günlük doğruluk oranı: %${accuracyStats.accuracy_rate || 0}\n`;
            
            // Yanlış tespit edilen örneklerden öğrenme
            const wrongPredictions = learningData.filter(data => 
                (data.actual_result === 'ai' && data.confidence_score < 70) ||
                (data.actual_result === 'human' && data.confidence_score > 70)
            );
            
            if (wrongPredictions.length > 0) {
                learningContext += `- Yanlış tespit sayısı: ${wrongPredictions.length}\n`;
                learningContext += `- Bu hatalardan ders çıkararak daha dikkatli analiz yap.\n`;
            }
        }

        const genAI = new GoogleGenerativeAI(GEMINI_API_KEY); /// GoogleGenerativeAI kütüphanesi kullanılarak Gemini AI modeli oluşturuluyor  
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" }); /// Gemini AI modeli oluşturuluyor

        const prompt = `Aşağıdaki metni analiz ederek AI tarafından yazılıp yazılmadığını tespit et:

Dosya: ${fileName}
İçerik: ${content.substring(0, 2000)}${content.length > 2000 ? '...' : ''}

AI Tespit Kriterleri:
1. Dil ve üslup tutarlılığı
2. Cümle yapısı çeşitliliği
3. Doğal dil akışı
4. Kişisel ifadeler ve deneyimler
5. Yazım hataları ve tutarsızlıklar
6. Tekrarlanan kalıplar
7. Aşırı mükemmel dilbilgisi
8. İnsan yazısına özgü özellikler
9. Duygusal ifadeler ve kişisel deneyimler
10. Yaratıcılık ve özgünlük${learningContext}

Analiz Sonucu (JSON formatında):
{
  "ai_probability": [0-100 arası sayı],
  "ai_detected": [true/false],
  "confidence_score": [0-100 arası sayı],
  "ai_indicators": ["belirti1", "belirti2", ...],
  "human_indicators": ["belirti1", "belirti2", ...],
  "detailed_analysis": "Detaylı açıklama",
  "recommendation": "Öneri"
}

Sadece JSON formatında yanıt ver, başka açıklama ekleme.`;

        let result, response, responseText;
        try {
            result = await model.generateContent(prompt); /// Gemini AI modeli ile prompt oluşturuluyor
            response = await result.response;
            responseText = response.text();
        } catch (geminiError) {
            console.error('Gemini API Hatası:', geminiError.message);
            
            // Gemini API hatası durumunda fallback analiz
            const fallbackAnalysis = {
                ai_probability: 50,
                ai_detected: false,
                confidence_score: 30,
                ai_indicators: ['API hatası nedeniyle analiz yapılamadı'],
                human_indicators: ['API hatası nedeniyle analiz yapılamadı'],
                detailed_analysis: `Gemini API şu anda kullanılamıyor: ${geminiError.message}. Lütfen daha sonra tekrar deneyin.`,
                recommendation: 'API hatası nedeniyle manuel kontrol önerilir'
            };
            
            return {
                success: true,
                analysis: `⚠️ AI Analizi Geçici Hatası: ${geminiError.message}. Lütfen birkaç dakika sonra tekrar deneyin.`,
                aiProbability: fallbackAnalysis.ai_probability,
                aiDetected: fallbackAnalysis.ai_detected,
                confidenceScore: fallbackAnalysis.confidence_score,
                aiIndicators: fallbackAnalysis.ai_indicators,
                humanIndicators: fallbackAnalysis.human_indicators,
                detailedAnalysis: fallbackAnalysis.detailed_analysis,
                recommendation: fallbackAnalysis.recommendation
            };
        }
        
        // JSON yanıtını parse et
        let analysisResult;
        try {
            // JSON'u temizle
            const cleanJson = responseText.replace(/```json|```/g, '').trim();
            analysisResult = JSON.parse(cleanJson);
        } catch (parseError) {
            // JSON parse edilemezse fallback
            analysisResult = {
                ai_probability: 50,
                ai_detected: false,
                confidence_score: 50,
                ai_indicators: ['Analiz hatası'],
                human_indicators: ['Analiz hatası'],
                detailed_analysis: responseText,
                recommendation: 'Manuel kontrol önerilir'
            };
        }

        // Analizi veritabanına kaydet
        const analysisId = await db.addAnalysis(
            userId,
            'text',
            fileName,
            content.substring(0, 500),
            analysisResult.ai_probability,
            analysisResult.ai_detected,
            JSON.stringify(analysisResult)
        );

        // Öğrenme verisi olarak kaydet
        await db.addLearningData(
            'text',
            {
                content_length: content.length,
                word_count: content.split(' ').length,
                sentence_count: content.split(/[.!?]+/).length,
                has_personal_pronouns: /ben|bana|beni|benim|biz|bize|bizi|bizim/i.test(content),
                has_emotions: /mutlu|üzgün|kızgın|heyecanlı|korku|sevinç/i.test(content),
                has_typos: /[a-zA-ZçğıöşüÇĞIİÖŞÜ]{20,}/.test(content),
                avg_sentence_length: content.split(/[.!?]+/).reduce((acc, sent) => acc + sent.split(' ').length, 0) / content.split(/[.!?]+/).length
            },
            'unknown', // Gerçek sonuç henüz bilinmiyor
            analysisResult.confidence_score
        );

        return {
            analysisId: analysisId,
            analysis: formatAnalysisResult(analysisResult),
            aiProbability: analysisResult.ai_probability,
            aiDetected: analysisResult.ai_detected,
            confidenceScore: analysisResult.confidence_score,
            rawResult: analysisResult
        };
    } catch (error) {
        return {
            analysis: `❌ AI Analizi Hatası: ${error.message}`,
            aiProbability: 50,
            aiDetected: false,
            confidenceScore: 0,
            error: true
        };
    }
}

// Resim analizi - OCR ile metin çıkarma ve AI tespiti
async function analyzeImage(imagePath, fileName, userId = 'anonymous') {
    try {
        if (!GEMINI_API_KEY || GEMINI_API_KEY === 'YOUR_GEMINI_API_KEY_HERE') {
            return {
                analysis: `🤖 DEMO RESİM ANALİZİ\n\n📷 ${fileName} resmi analiz edildi.\n\n⚠️ Gemini API anahtarı gerekli!\n\n🔧 Ayarlama:\n1. https://makersuite.google.com/app/apikey adresinden API anahtarı alın\n2. server.js dosyasında GEMINI_API_KEY değişkenini güncelleyin\n3. Sistemi yeniden başlatın`,
                aiProbability: 50,
                aiDetected: false,
                confidenceScore: 0
            };
        }

        // OCR ile resimden metin çıkar
        console.log('🔍 Resimden metin çıkarılıyor...');
        const { data: { text } } = await Tesseract.recognize(imagePath, 'tur', {
            logger: m => console.log(m)
        });

        if (!text || text.trim().length < 10) {
            return {
                analysis: `📷 Resim Analizi\n\n❌ Resimden yeterli metin çıkarılamadı.\n\n💡 Öneriler:\n• Daha net bir resim yükleyin\n• Metin içeren bir resim seçin\n• Resim kalitesini artırın`,
                aiProbability: 0,
                aiDetected: false,
                confidenceScore: 0
            };
        }

        console.log('📝 Çıkarılan metin:', text.substring(0, 100) + '...');

        // Çıkarılan metni AI ile analiz et
        const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

        const prompt = `Aşağıdaki metin bir resimden OCR ile çıkarılmıştır. Bu metnin AI tarafından yazılıp yazılmadığını tespit et:

Dosya: ${fileName}
Çıkarılan Metin: ${text.substring(0, 2000)}${text.length > 2000 ? '...' : ''}

AI Tespit Kriterleri:
1. Dil ve üslup tutarlılığı
2. Cümle yapısı çeşitliliği
3. Doğal dil akışı
4. Kişisel ifadeler ve deneyimler
5. Yazım hataları ve tutarsızlıklar
6. Tekrarlanan kalıplar
7. Aşırı mükemmel dilbilgisi
8. İnsan yazısına özgü özellikler
9. Duygusal ifadeler ve kişisel deneyimler
10. Yaratıcılık ve özgünlük

Analiz Sonucu (JSON formatında):
{
  "ai_probability": [0-100 arası sayı],
  "ai_detected": [true/false],
  "confidence_score": [0-100 arası sayı],
  "ai_indicators": ["belirti1", "belirti2", ...],
  "human_indicators": ["belirti1", "belirti2", ...],
  "detailed_analysis": "Detaylı açıklama",
  "recommendation": "Öneri",
  "extracted_text": "Çıkarılan metin özeti"
}

Sadece JSON formatında yanıt ver, başka açıklama ekleme.`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const responseText = response.text();
        
        // JSON yanıtını parse et
        let analysisResult;
        try {
            const cleanJson = responseText.replace(/```json|```/g, '').trim();
            analysisResult = JSON.parse(cleanJson);
        } catch (parseError) {
            analysisResult = {
                ai_probability: 50,
                ai_detected: false,
                confidence_score: 50,
                ai_indicators: ['Analiz hatası'],
                human_indicators: ['Analiz hatası'],
                detailed_analysis: responseText,
                recommendation: 'Manuel kontrol önerilir',
                extracted_text: text.substring(0, 200)
            };
        }

        // Analizi veritabanına kaydet
        const analysisId = await db.addAnalysis(
            userId,
            'image',
            fileName,
            text.substring(0, 500),
            analysisResult.ai_probability,
            analysisResult.ai_detected,
            JSON.stringify(analysisResult)
        );

        return {
            analysisId: analysisId,
            analysis: formatImageAnalysisResult(analysisResult, text),
            aiProbability: analysisResult.ai_probability,
            aiDetected: analysisResult.ai_detected,
            confidenceScore: analysisResult.confidence_score,
            rawResult: analysisResult,
            extractedText: text
        };
    } catch (error) {
        return {
            analysis: `❌ Resim Analizi Hatası: ${error.message}`,
            aiProbability: 50,
            aiDetected: false,
            confidenceScore: 0,
            error: true
        };
    }
}

// Analiz sonucunu formatla
function formatAnalysisResult(result) {
    let formatted = `🔍 AI TESPİT ANALİZİ\n\n`;
    formatted += `📊 AI Tarafından Yazılma Olasılığı: %${result.ai_probability}\n`;
    formatted += `🎯 Tespit Sonucu: ${result.ai_detected ? '🤖 AI TARAFINDAN YAZILMIŞ' : '👤 İNSAN TARAFINDAN YAZILMIŞ'}\n`;
    formatted += `📈 Güven Skoru: %${result.confidence_score}\n\n`;
    
    if (result.ai_indicators && result.ai_indicators.length > 0) {
        formatted += `🤖 AI Belirtileri:\n`;
        result.ai_indicators.forEach(indicator => {
            formatted += `• ${indicator}\n`;
        });
        formatted += `\n`;
    }
    
    if (result.human_indicators && result.human_indicators.length > 0) {
        formatted += `👤 İnsan Yazısı Belirtileri:\n`;
        result.human_indicators.forEach(indicator => {
            formatted += `• ${indicator}\n`;
        });
        formatted += `\n`;
    }
    
    formatted += `📝 Detaylı Analiz:\n${result.detailed_analysis}\n\n`;
    formatted += `💡 Öneri:\n${result.recommendation}`;
    
    return formatted;
}

// Resim analiz sonucunu formatla
function formatImageAnalysisResult(result, extractedText) {
    let formatted = `📷 RESİM AI TESPİT ANALİZİ\n\n`;
    formatted += `📊 AI Tarafından Yazılma Olasılığı: %${result.ai_probability}\n`;
    formatted += `🎯 Tespit Sonucu: ${result.ai_detected ? '🤖 AI TARAFINDAN YAZILMIŞ' : '👤 İNSAN TARAFINDAN YAZILMIŞ'}\n`;
    formatted += `📈 Güven Skoru: %${result.confidence_score}\n\n`;
    
    formatted += `📝 Çıkarılan Metin:\n${extractedText.substring(0, 300)}${extractedText.length > 300 ? '...' : ''}\n\n`;
    
    if (result.ai_indicators && result.ai_indicators.length > 0) {
        formatted += `🤖 AI Belirtileri:\n`;
        result.ai_indicators.forEach(indicator => {
            formatted += `• ${indicator}\n`;
        });
        formatted += `\n`;
    }
    
    if (result.human_indicators && result.human_indicators.length > 0) {
        formatted += `👤 İnsan Yazısı Belirtileri:\n`;
        result.human_indicators.forEach(indicator => {
            formatted += `• ${indicator}\n`;
        });
        formatted += `\n`;
    }
    
    formatted += `📝 Detaylı Analiz:\n${result.detailed_analysis}\n\n`;
    formatted += `💡 Öneri:\n${result.recommendation}`;
    
    return formatted;
}

// Ana sayfa
app.get('/', (req, res) => { /// express kütüphanesi kullanılarak ana sayfa oluşturuluyor
    res.sendFile(__dirname + '/public/index.html');
});

// Giriş endpoint'i
app.post('/api/login', async (req, res) => { /// express kütüphanesi kullanılarak giriş endpoint'i oluşturuluyor
    try {
        const { username, password } = req.body;
        
        if (!username || !password) {
            return res.status(400).json({ 
                success: false, 
                message: 'Kullanıcı adı ve şifre gerekli' 
            });
        }
        
        // Kullanıcıyı veritabanından bul
        const user = await db.getUserByUsername(username);
        
        if (!user) {
            return res.status(401).json({ 
                success: false, 
                message: 'Kullanıcı adı veya şifre hatalı' 
            });
        }
        
        // Şifre doğrulama
        const isValidPassword = await bcrypt.compare(password, user.password_hash);
        
        if (!isValidPassword) {
            return res.status(401).json({ 
                success: false, 
                message: 'Kullanıcı adı veya şifre hatalı' 
            });
        }
        
        // Giriş zamanını güncelle
        await db.updateLastLogin(username);
        
        // Kullanıcı abonelik bilgilerini getir
        const subscription = await db.getUserSubscription(username);
        
        res.json({ 
            success: true, 
            message: 'Giriş başarılı',
            user: {
                username: user.username,
                name: user.name,
                role: user.role,
                subscription: subscription ? {
                    tier: subscription.tier,
                    name: subscription.name,
                    description: subscription.description,
                    price: subscription.price,
                    wordLimit: subscription.word_limit,
                    fileUploadLimit: subscription.file_upload_limit,
                    hasImageUpload: subscription.has_image_upload === 1,
                    isUnlimited: subscription.is_unlimited === 1,
                    dailyWordUsage: subscription.daily_word_usage || 0,
                    dailyFileUsage: subscription.daily_file_usage || 0
                } : {
                    tier: 'basic',
                    name: 'Temel',
                    description: 'Günlük temel kullanım için',
                    price: 0.0,
                    wordLimit: 1000,
                    fileUploadLimit: 5,
                    hasImageUpload: false,
                    isUnlimited: false,
                    dailyWordUsage: 0,
                    dailyFileUsage: 0
                }
            }
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: 'Sunucu hatası: ' + error.message 
        });
    }
});

// Ödev analizi (dosya)
app.post('/api/check-homework', upload.single('homework'), async (req, res) => { /// express kütüphanesi kullanılarak ödev analizi yapılıyor
    try {
        if (!req.file) return res.status(400).json({ error: 'Dosya yüklenmedi' });
        
        const userId = req.body.userId || 'anonymous';
        
        // Kullanım limitlerini kontrol et
        if (userId && userId !== 'anonymous') {
            const usageLimits = await db.checkUsageLimits(userId, 0, true);
            
            if (!usageLimits.canUploadFile) {
                fs.unlinkSync(req.file.path); // Dosyayı temizle
                return res.status(429).json({ 
                    error: `Günlük dosya yükleme limitinizi aştınız. Mevcut limit: ${usageLimits.fileUploadLimit} dosya`,
                    limitExceeded: true,
                    fileUploadLimit: usageLimits.fileUploadLimit,
                    dailyFileUsage: usageLimits.dailyFileUsage
                });
            }
        }
        
        const content = fs.readFileSync(req.file.path, 'utf8'); // fs kütüphanesi kullanılarak dosya okunuyor
        const result = await analyzeHomework(content, req.file.originalname, userId);
        
        // Kullanım sayacını güncelle
        if (userId && userId !== 'anonymous') {
            await db.updateUsage(userId, 0, true);
        }
        
        fs.unlinkSync(req.file.path); // Dosyayı temizle # fs kütüphanesi kullanılarak dosya siliniyor
        
        res.json({ 
            success: true, 
            analysis: result.analysis,
            analysisId: result.analysisId,
            aiProbability: result.aiProbability,
            aiDetected: result.aiDetected,
            confidenceScore: result.confidenceScore
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Ödev analizi (metin)
app.post('/api/check-text', async (req, res) => { /// express kütüphanesi kullanılarak ödev analizi yapılıyor
    try {
        const { content, userId } = req.body;
        if (!content) return res.status(400).json({ error: 'Metin gerekli' });
        
        // Kullanım limitlerini kontrol et
        if (userId && userId !== 'anonymous') {
            const wordCount = content.split(/\s+/).length;
            const usageLimits = await db.checkUsageLimits(userId, wordCount);
            
            if (!usageLimits.canAnalyzeText) {
                return res.status(429).json({ 
                    error: `Günlük kelime limitinizi aştınız. Mevcut limit: ${usageLimits.wordLimit} kelime`,
                    limitExceeded: true,
                    wordLimit: usageLimits.wordLimit,
                    dailyWordUsage: usageLimits.dailyWordUsage
                });
            }
        }
        
        const result = await analyzeHomework(content, 'Metin Girişi', userId || 'anonymous'); /// analyzeHomework fonksiyonu çağrılıyor
        
        // Kullanım sayacını güncelle
        if (userId && userId !== 'anonymous') {
            const wordCount = content.split(/\s+/).length;
            await db.updateUsage(userId, wordCount, false);
        }
        
        res.json({ 
            success: true, 
            analysis: result.analysis,
            analysisId: result.analysisId,
            aiProbability: result.aiProbability,
            aiDetected: result.aiDetected,
            confidenceScore: result.confidenceScore
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Resim analizi endpoint'i
app.post('/api/check-image', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: 'Resim yüklenmedi' });
        
        const userId = req.body.userId || 'anonymous';
        
        // Kullanım limitlerini kontrol et
        if (userId && userId !== 'anonymous') {
            const usageLimits = await db.checkUsageLimits(userId, 0, true);
            
            if (!usageLimits.canUploadFile) {
                fs.unlinkSync(req.file.path); // Dosyayı temizle
                return res.status(429).json({ 
                    error: `Günlük dosya yükleme limitinizi aştınız. Mevcut limit: ${usageLimits.fileUploadLimit} dosya`,
                    limitExceeded: true,
                    fileUploadLimit: usageLimits.fileUploadLimit,
                    dailyFileUsage: usageLimits.dailyFileUsage
                });
            }
            
            if (!usageLimits.canUploadImage) {
                fs.unlinkSync(req.file.path); // Dosyayı temizle
                return res.status(403).json({ 
                    error: 'Resim yükleme özelliği aboneliğinizde mevcut değil',
                    featureNotAvailable: true
                });
            }
        }
        
        const result = await analyzeImage(req.file.path, req.file.originalname, userId);
        
        // Kullanım sayacını güncelle
        if (userId && userId !== 'anonymous') {
            await db.updateUsage(userId, 0, true);
        }
        
        fs.unlinkSync(req.file.path); // Dosyayı temizle
        
        res.json({ 
            success: true, 
            analysis: result.analysis,
            analysisId: result.analysisId,
            aiProbability: result.aiProbability,
            aiDetected: result.aiDetected,
            confidenceScore: result.confidenceScore,
            extractedText: result.extractedText
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Geri bildirim endpoint'i
app.post('/api/feedback', async (req, res) => { /// express kütüphanesi kullanılarak geri bildirim endpoint'i oluşturuluyor
    try {
        const { analysisId, userId, isCorrect, actualResult, feedbackNotes } = req.body;
        
        if (!analysisId || !userId || typeof isCorrect !== 'boolean') {
            return res.status(400).json({ error: 'Gerekli alanlar eksik' });
        }
        
        const feedbackId = await db.addFeedback(analysisId, userId, isCorrect, actualResult, feedbackNotes);
        
        // Öğrenme verisini güncelle
        if (actualResult) {
            const analysis = await db.getAnalysisHistory(1);
            if (analysis.length > 0) {
                await db.addLearningData(
                    'text',
                    {
                        content_length: analysis[0].content_preview.length,
                        word_count: analysis[0].content_preview.split(' ').length,
                        sentence_count: analysis[0].content_preview.split(/[.!?]+/).length,
                        has_personal_pronouns: /ben|bana|beni|benim|biz|bize|bizi|bizim/i.test(analysis[0].content_preview),
                        has_emotions: /mutlu|üzgün|kızgın|heyecanlı|korku|sevinç/i.test(analysis[0].content_preview),
                        has_typos: /[a-zA-ZçğıöşüÇĞIİÖŞÜ]{20,}/.test(analysis[0].content_preview),
                        avg_sentence_length: analysis[0].content_preview.split(/[.!?]+/).reduce((acc, sent) => acc + sent.split(' ').length, 0) / analysis[0].content_preview.split(/[.!?]+/).length
                    },
                    actualResult,
                    analysis[0].ai_probability
                );
            }
        }
        
        // Performans metriklerini güncelle
        await db.updatePerformanceMetrics();
        
        res.json({ success: true, feedbackId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// İstatistikler endpoint'i
app.get('/api/stats', async (req, res) => { /// express kütüphanesi kullanılarak istatistikler endpoint'i oluşturuluyor
    try {
        const accuracyStats = await db.getAccuracyRate(30);
        const detectionStats = await db.getDetectionStats();
        const recentAnalyses = await db.getAnalysisHistory(10);
        
        res.json({
            success: true,
            stats: {
                accuracy: accuracyStats,
                detection: detectionStats,
                recentAnalyses: recentAnalyses
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Abonelik planlarını getir
app.get('/api/subscription-plans', async (req, res) => {
    try {
        const plans = await db.getSubscriptionPlans();
        res.json({
            success: true,
            plans: plans
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Abonelik güncelle
app.post('/api/update-subscription', async (req, res) => {
    try {
        const { userId, subscriptionTier } = req.body;
        
        if (!userId || !subscriptionTier) {
            return res.status(400).json({ error: 'Kullanıcı ID ve abonelik seviyesi gerekli' });
        }
        
        await db.updateUserSubscription(userId, subscriptionTier);
        
        res.json({
            success: true,
            message: 'Abonelik başarıyla güncellendi'
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Kullanım limitlerini kontrol et
app.get('/api/usage-limits/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        
        const usageLimits = await db.checkUsageLimits(userId);
        
        res.json({
            success: true,
            usageLimits: usageLimits
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => { /// express kütüphanesi kullanılarak server başlatılıyor
    console.log(`🚀 Server ${PORT} portunda çalışıyor`);
    console.log(`📱 http://localhost:${PORT}`);
    console.log(`👤 Giriş: user / user123`);
});
