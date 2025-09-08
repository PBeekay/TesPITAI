const sqlite3 = require('sqlite3').verbose();
const path = require('path');

class Database {
    constructor() {
        this.db = new sqlite3.Database('./ai_detection.db', (err) => {
            if (err) {
                console.error('Veritabanı bağlantı hatası:', err.message);
            } else {
                console.log('✅ Veritabanı bağlantısı başarılı');
                this.initTables();
            }
        });
    }

    // Tabloları oluştur
    initTables() {
        // Kullanıcılar tablosu
        this.db.run(`
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                name TEXT,
                role TEXT DEFAULT 'user',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                last_login DATETIME
            )
        `);

        // Analiz geçmişi tablosu
        this.db.run(`
            CREATE TABLE IF NOT EXISTS analysis_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                content_type TEXT NOT NULL, -- 'file' veya 'text'
                file_name TEXT,
                content_preview TEXT,
                ai_probability REAL,
                ai_detected BOOLEAN,
                analysis_result TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Kullanıcı geri bildirimleri tablosu
        this.db.run(`
            CREATE TABLE IF NOT EXISTS user_feedback (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                analysis_id INTEGER,
                user_id TEXT NOT NULL,
                is_correct BOOLEAN NOT NULL,
                actual_result TEXT, -- 'ai' veya 'human'
                feedback_notes TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (analysis_id) REFERENCES analysis_history (id)
            )
        `);

        // Öğrenme verileri tablosu
        this.db.run(`
            CREATE TABLE IF NOT EXISTS learning_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content_type TEXT NOT NULL,
                content_features TEXT, -- JSON formatında özellikler
                actual_result TEXT NOT NULL, -- 'ai' veya 'human'
                confidence_score REAL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Sistem performans metrikleri
        this.db.run(`
            CREATE TABLE IF NOT EXISTS performance_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date DATE NOT NULL,
                total_analyses INTEGER DEFAULT 0,
                correct_predictions INTEGER DEFAULT 0,
                accuracy_rate REAL DEFAULT 0.0,
                ai_detected_count INTEGER DEFAULT 0,
                human_detected_count INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Abonelik planları tablosu
        this.db.run(`
            CREATE TABLE IF NOT EXISTS subscription_plans (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                tier TEXT UNIQUE NOT NULL,
                name TEXT NOT NULL,
                description TEXT,
                price REAL DEFAULT 0.0,
                word_limit INTEGER DEFAULT 1000,
                file_upload_limit INTEGER DEFAULT 5,
                has_image_upload BOOLEAN DEFAULT 0,
                is_unlimited BOOLEAN DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Kullanıcı abonelikleri tablosu
        this.db.run(`
            CREATE TABLE IF NOT EXISTS user_subscriptions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                subscription_tier TEXT NOT NULL,
                daily_word_usage INTEGER DEFAULT 0,
                daily_file_usage INTEGER DEFAULT 0,
                last_usage_reset DATE DEFAULT CURRENT_DATE,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (username)
            )
        `);

        // Abonelik planlarını başlat
        setTimeout(() => {
            this.initializeSubscriptionPlans();
        }, 2000);
    }

    // Kullanıcı oluştur
    createUser(username, passwordHash, name, role = 'user') {
        return new Promise((resolve, reject) => {
            const stmt = this.db.prepare(`
                INSERT INTO users (username, password_hash, name, role)
                VALUES (?, ?, ?, ?)
            `);
            
            stmt.run([username, passwordHash, name, role], function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.lastID);
                }
            });
            
            stmt.finalize();
        });
    }

    // Kullanıcı giriş doğrulama
    authenticateUser(username, passwordHash) {
        return new Promise((resolve, reject) => {
            this.db.get(`
                SELECT id, username, name, role, last_login
                FROM users 
                WHERE username = ? AND password_hash = ?
            `, [username, passwordHash], (err, row) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(row);
                }
            });
        });
    }

    // Kullanıcı giriş zamanını güncelle
    updateLastLogin(username) {
        return new Promise((resolve, reject) => {
            this.db.run(`
                UPDATE users 
                SET last_login = CURRENT_TIMESTAMP 
                WHERE username = ?
            `, [username], function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.changes);
                }
            });
        });
    }

    // Kullanıcı bilgilerini getir
    getUserByUsername(username) {
        return new Promise((resolve, reject) => {
            this.db.get(`
                SELECT id, username, name, role, password_hash, created_at, last_login
                FROM users 
                WHERE username = ?
            `, [username], (err, row) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(row);
                }
            });
        });
    }

    // Analiz kaydı ekle
    addAnalysis(userId, contentType, fileName, contentPreview, aiProbability, aiDetected, analysisResult) {
        return new Promise((resolve, reject) => {
            const stmt = this.db.prepare(`
                INSERT INTO analysis_history 
                (user_id, content_type, file_name, content_preview, ai_probability, ai_detected, analysis_result)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            `);
            
            stmt.run([userId, contentType, fileName, contentPreview, aiProbability, aiDetected, analysisResult], function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.lastID);
                }
            });
            
            stmt.finalize();
        });
    }

    // Geri bildirim ekle
    addFeedback(analysisId, userId, isCorrect, actualResult, feedbackNotes) {
        return new Promise((resolve, reject) => {
            const stmt = this.db.prepare(`
                INSERT INTO user_feedback 
                (analysis_id, user_id, is_correct, actual_result, feedback_notes)
                VALUES (?, ?, ?, ?, ?)
            `);
            
            stmt.run([analysisId, userId, isCorrect, actualResult, feedbackNotes], function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.lastID);
                }
            });
            
            stmt.finalize();
        });
    }

    // Öğrenme verisi ekle
    addLearningData(contentType, contentFeatures, actualResult, confidenceScore) {
        return new Promise((resolve, reject) => {
            const stmt = this.db.prepare(`
                INSERT INTO learning_data 
                (content_type, content_features, actual_result, confidence_score)
                VALUES (?, ?, ?, ?)
            `);
            
            stmt.run([contentType, JSON.stringify(contentFeatures), actualResult, confidenceScore], function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.lastID);
                }
            });
            
            stmt.finalize();
        });
    }

    // Geçmiş analizleri getir
    getAnalysisHistory(limit = 100) {
        return new Promise((resolve, reject) => {
            this.db.all(`
                SELECT h.*, f.is_correct, f.actual_result, f.feedback_notes
                FROM analysis_history h
                LEFT JOIN user_feedback f ON h.id = f.analysis_id
                ORDER BY h.created_at DESC
                LIMIT ?
            `, [limit], (err, rows) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(rows);
                }
            });
        });
    }

    // Doğruluk oranını hesapla
    getAccuracyRate(days = 30) {
        return new Promise((resolve, reject) => {
            this.db.get(`
                SELECT 
                    COUNT(*) as total_feedback,
                    SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct_count,
                    ROUND(
                        (SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
                    ) as accuracy_rate
                FROM user_feedback 
                WHERE created_at >= datetime('now', '-${days} days')
            `, (err, row) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(row);
                }
            });
        });
    }

    // AI tespit istatistikleri
    getDetectionStats() {
        return new Promise((resolve, reject) => {
            this.db.all(`
                SELECT 
                    actual_result,
                    COUNT(*) as count,
                    ROUND(AVG(ai_probability), 2) as avg_probability
                FROM user_feedback f
                JOIN analysis_history h ON f.analysis_id = h.id
                GROUP BY actual_result
            `, (err, rows) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(rows);
                }
            });
        });
    }

    // Öğrenme verilerini getir
    getLearningData(limit = 1000) {
        return new Promise((resolve, reject) => {
            this.db.all(`
                SELECT content_type, content_features, actual_result, confidence_score
                FROM learning_data
                ORDER BY created_at DESC
                LIMIT ?
            `, [limit], (err, rows) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(rows.map(row => ({
                        ...row,
                        content_features: JSON.parse(row.content_features)
                    })));
                }
            });
        });
    }

    // Performans metriklerini güncelle
    updatePerformanceMetrics() {
        return new Promise((resolve, reject) => {
            const today = new Date().toISOString().split('T')[0];
            
            this.db.get(`
                SELECT COUNT(*) as total, 
                       SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct
                FROM user_feedback 
                WHERE DATE(created_at) = ?
            `, [today], (err, row) => {
                if (err) {
                    reject(err);
                } else {
                    const accuracy = row.total > 0 ? (row.correct / row.total) * 100 : 0;
                    
                    this.db.run(`
                        INSERT OR REPLACE INTO performance_metrics 
                        (date, total_analyses, correct_predictions, accuracy_rate)
                        VALUES (?, ?, ?, ?)
                    `, [today, row.total, row.correct, accuracy], (err) => {
                        if (err) {
                            reject(err);
                        } else {
                            resolve();
                        }
                    });
                }
            });
        });
    }

    // Abonelik planlarını başlat
    initializeSubscriptionPlans() {
        const plans = [
            {
                tier: 'basic',
                name: 'Temel',
                description: 'Günlük temel kullanım için',
                price: 0.0,
                word_limit: 1000,
                file_upload_limit: 5,
                has_image_upload: 0,
                is_unlimited: 0
            },
            {
                tier: 'pro',
                name: 'Profesyonel',
                description: 'Gelişmiş özellikler ve daha fazla kullanım',
                price: 29.99,
                word_limit: 10000,
                file_upload_limit: 50,
                has_image_upload: 1,
                is_unlimited: 0
            },
            {
                tier: 'unlimited',
                name: 'Sınırsız',
                description: 'Tüm özellikler ve sınırsız kullanım',
                price: 99.99,
                word_limit: -1,
                file_upload_limit: -1,
                has_image_upload: 1,
                is_unlimited: 1
            }
        ];

        plans.forEach(plan => {
            this.db.run(`
                INSERT OR IGNORE INTO subscription_plans 
                (tier, name, description, price, word_limit, file_upload_limit, has_image_upload, is_unlimited)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            `, [
                plan.tier, plan.name, plan.description, plan.price,
                plan.word_limit, plan.file_upload_limit, plan.has_image_upload, plan.is_unlimited
            ]);
        });
    }

    // Kullanıcı abonelik bilgilerini getir
    getUserSubscription(username) {
        return new Promise((resolve, reject) => {
            this.db.get(`
                SELECT s.*, p.name, p.description, p.price, p.word_limit, p.file_upload_limit, 
                       p.has_image_upload, p.is_unlimited
                FROM user_subscriptions s
                JOIN subscription_plans p ON s.subscription_tier = p.tier
                WHERE s.user_id = ?
            `, [username], (err, row) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(row);
                }
            });
        });
    }

    // Kullanıcı abonelik oluştur/güncelle
    updateUserSubscription(username, subscriptionTier) {
        return new Promise((resolve, reject) => {
            this.db.run(`
                INSERT OR REPLACE INTO user_subscriptions 
                (user_id, subscription_tier, daily_word_usage, daily_file_usage, last_usage_reset, updated_at)
                VALUES (?, ?, 0, 0, CURRENT_DATE, CURRENT_TIMESTAMP)
            `, [username, subscriptionTier], function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.lastID);
                }
            });
        });
    }

    // Kullanım limitlerini kontrol et
    checkUsageLimits(username, wordCount = 0, isFileUpload = false) {
        return new Promise((resolve, reject) => {
            this.db.get(`
                SELECT s.*, p.word_limit, p.file_upload_limit, p.has_image_upload, p.is_unlimited
                FROM user_subscriptions s
                JOIN subscription_plans p ON s.subscription_tier = p.tier
                WHERE s.user_id = ?
            `, [username], (err, row) => {
                if (err) {
                    reject(err);
                } else if (!row) {
                    // Varsayılan temel plan
                    resolve({
                        canAnalyzeText: wordCount <= 1000,
                        canUploadFile: true,
                        canUploadImage: false,
                        wordLimit: 1000,
                        fileUploadLimit: 5,
                        dailyWordUsage: 0,
                        dailyFileUsage: 0
                    });
                } else {
                    // Günlük kullanımı sıfırla (yeni gün ise)
                    const today = new Date().toISOString().split('T')[0];
                    if (row.last_usage_reset !== today) {
                        this.resetDailyUsage(username);
                        row.daily_word_usage = 0;
                        row.daily_file_usage = 0;
                    }

                    const canAnalyzeText = row.is_unlimited || row.word_limit === -1 || 
                                         (row.daily_word_usage + wordCount) <= row.word_limit;
                    const canUploadFile = row.is_unlimited || row.file_upload_limit === -1 || 
                                        row.daily_file_usage < row.file_upload_limit;

                    resolve({
                        canAnalyzeText,
                        canUploadFile,
                        canUploadImage: row.has_image_upload === 1,
                        wordLimit: row.word_limit,
                        fileUploadLimit: row.file_upload_limit,
                        dailyWordUsage: row.daily_word_usage,
                        dailyFileUsage: row.daily_file_usage
                    });
                }
            });
        });
    }

    // Günlük kullanımı sıfırla
    resetDailyUsage(username) {
        return new Promise((resolve, reject) => {
            this.db.run(`
                UPDATE user_subscriptions 
                SET daily_word_usage = 0, daily_file_usage = 0, last_usage_reset = CURRENT_DATE
                WHERE user_id = ?
            `, [username], function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.changes);
                }
            });
        });
    }

    // Kullanım sayacını güncelle
    updateUsage(username, wordCount = 0, fileUploaded = false) {
        return new Promise((resolve, reject) => {
            let updateQuery = 'UPDATE user_subscriptions SET ';
            let params = [];
            
            if (wordCount > 0) {
                updateQuery += 'daily_word_usage = daily_word_usage + ?, ';
                params.push(wordCount);
            }
            
            if (fileUploaded) {
                updateQuery += 'daily_file_usage = daily_file_usage + 1, ';
            }
            
            updateQuery += 'updated_at = CURRENT_TIMESTAMP WHERE user_id = ?';
            params.push(username);
            
            this.db.run(updateQuery, params, function(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve(this.changes);
                }
            });
        });
    }

    // Abonelik planlarını getir
    getSubscriptionPlans() {
        return new Promise((resolve, reject) => {
            this.db.all(`
                SELECT tier, name, description, price, word_limit, file_upload_limit, 
                       has_image_upload, is_unlimited
                FROM subscription_plans
                ORDER BY price ASC
            `, (err, rows) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(rows);
                }
            });
        });
    }

    // Veritabanını kapat
    close() {
        this.db.close((err) => {
            if (err) {
                console.error('Veritabanı kapatma hatası:', err.message);
            } else {
                console.log('✅ Veritabanı bağlantısı kapatıldı');
            }
        });
    }
}

module.exports = Database;
