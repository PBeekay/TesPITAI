// Global variables
let currentUser = null;
let currentAnalysisId = null;
let currentAnalysisData = null;

// DOM elements
const loginPage = document.getElementById('loginPage');
const mainPage = document.getElementById('mainPage');
const loginForm = document.getElementById('loginForm');
const currentUserSpan = document.getElementById('currentUser');
const logoutBtn = document.getElementById('logoutBtn');

// Initialize app
document.addEventListener('DOMContentLoaded', function() {
    checkLoginStatus();
    setupEventListeners();
});

// Check if user is logged in
function checkLoginStatus() {
    const savedUser = localStorage.getItem('currentUser');
    if (savedUser) {
        currentUser = savedUser;
        showMainPage();
    } else {
        showLoginPage();
    }
}

// Setup event listeners
function setupEventListeners() {
    // Login form
    loginForm.addEventListener('submit', handleLogin);
    
    // Logout button
    logoutBtn.addEventListener('click', handleLogout);
    
    // Tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', handleTabChange);
    });
    
    // File upload area
    const dropZone = document.getElementById('dropZone');
    const fileInput = document.getElementById('fileInput');
    
    dropZone.addEventListener('click', () => fileInput.click());
    dropZone.addEventListener('dragover', handleDragOver);
    dropZone.addEventListener('dragleave', handleDragLeave);
    dropZone.addEventListener('drop', handleDrop);
    
    // File input
    fileInput.addEventListener('change', handleFileSelect);
    
    // Forms
    document.getElementById('fileForm').addEventListener('submit', handleFileUpload);
    document.getElementById('textForm').addEventListener('submit', handleTextUpload);
    
    // Feedback buttons
    document.getElementById('correctBtn').addEventListener('click', () => handleFeedback(true));
    document.getElementById('incorrectBtn').addEventListener('click', () => handleFeedback(false));
    document.getElementById('submitFeedback').addEventListener('click', submitFeedback);
    document.getElementById('cancelFeedback').addEventListener('click', cancelFeedback);
}

// Show login page
function showLoginPage() {
    loginPage.style.display = 'block';
    mainPage.style.display = 'none';
}

// Show main page
function showMainPage() {
    loginPage.style.display = 'none';
    mainPage.style.display = 'block';
    currentUserSpan.textContent = `Hoş geldiniz, ${currentUser}!`;
}

// Handle login
async function handleLogin(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    
    if (!username || !password) {
        alert('Lütfen kullanıcı adı ve şifrenizi girin!');
        return;
    }
    
    try {
        const response = await fetch('/api/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (data.success) {
            currentUser = username;
            localStorage.setItem('currentUser', currentUser);
            showMainPage();
            loginForm.reset();
        } else {
            alert('Giriş başarısız: ' + data.message);
        }
    } catch (error) {
        alert('Bağlantı hatası: ' + error.message);
    }
}

// Handle logout
function handleLogout() {
    currentUser = null;
    localStorage.removeItem('currentUser');
    showLoginPage();
    resetForms();
}

// Handle tab change
function handleTabChange(e) {
    const tabName = e.target.dataset.tab;
    
    // Update active tab button
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    e.target.classList.add('active');
    
    // Update active tab content
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.getElementById(tabName + 'Tab').classList.add('active');
    
    // Hide results
    hideResult();
}

// Handle drag over
function handleDragOver(e) {
    e.preventDefault();
    const dropZone = document.getElementById('dropZone');
    dropZone.style.borderColor = '#667eea';
    dropZone.style.background = '#f8f9ff';
}

// Handle drag leave
function handleDragLeave(e) {
    e.preventDefault();
    const dropZone = document.getElementById('dropZone');
    dropZone.style.borderColor = '#ddd';
    dropZone.style.background = 'white';
}

// Handle drop
function handleDrop(e) {
    e.preventDefault();
    const dropZone = document.getElementById('dropZone');
    dropZone.style.borderColor = '#ddd';
    dropZone.style.background = 'white';
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        handleFile(files[0]);
    }
}

// Handle file select
function handleFileSelect(e) {
    const file = e.target.files[0];
    if (file) {
        handleFile(file);
    }
}

// Handle file
function handleFile(file) {
    const dropZone = document.getElementById('dropZone');
    dropZone.querySelector('p').textContent = `📁 ${file.name}`;
}

// Handle file upload
async function handleFileUpload(e) {
    e.preventDefault();
    
    const fileInput = document.getElementById('fileInput');
    if (!fileInput.files[0]) {
        alert('Lütfen bir dosya seçin');
        return;
    }
    
    const formData = new FormData();
    formData.append('homework', fileInput.files[0]);
    formData.append('userId', currentUser);
    
    showLoading();
    
    try {
        const response = await fetch('/api/check-homework', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            currentAnalysisId = data.analysisId;
            currentAnalysisData = data;
            showResult(data.analysis);
        } else {
            alert('Hata: ' + data.error);
        }
    } catch (error) {
        alert('Hata: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Handle text upload
async function handleTextUpload(e) {
    e.preventDefault();
    
    const text = document.getElementById('textInput').value.trim();
    if (!text) {
        alert('Lütfen metin girin');
        return;
    }
    
    showLoading();
    
    try {
        const response = await fetch('/api/check-text', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ 
                content: text,
                userId: currentUser
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            currentAnalysisId = data.analysisId;
            currentAnalysisData = data;
            showResult(data.analysis);
        } else {
            alert('Hata: ' + data.error);
        }
    } catch (error) {
        alert('Hata: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Handle feedback
function handleFeedback(isCorrect) {
    if (isCorrect) {
        // Doğru tespit - sadece başarı mesajı göster
        showFeedbackSuccess();
    } else {
        // Yanlış tespit - geri bildirim formunu göster
        showFeedbackForm();
    }
}

// Show feedback form
function showFeedbackForm() {
    document.getElementById('feedbackForm').classList.remove('hidden');
    document.getElementById('feedbackSuccess').classList.add('hidden');
}

// Show feedback success
function showFeedbackSuccess() {
    document.getElementById('feedbackForm').classList.add('hidden');
    document.getElementById('feedbackSuccess').classList.remove('hidden');
    
    // Geri bildirim gönder (doğru tespit)
    submitFeedbackToServer(true, null, null);
}

// Cancel feedback
function cancelFeedback() {
    document.getElementById('feedbackForm').classList.add('hidden');
    document.getElementById('feedbackSuccess').classList.add('hidden');
}

// Submit feedback
async function submitFeedback() {
    const actualResult = document.querySelector('input[name="actualResult"]:checked');
    const feedbackNotes = document.getElementById('feedbackNotes').value;
    
    if (!actualResult) {
        alert('Lütfen gerçek sonucu seçin');
        return;
    }
    
    const isCorrect = (actualResult.value === 'ai' && currentAnalysisData.aiDetected) ||
                     (actualResult.value === 'human' && !currentAnalysisData.aiDetected);
    
    await submitFeedbackToServer(isCorrect, actualResult.value, feedbackNotes);
    
    document.getElementById('feedbackForm').classList.add('hidden');
    document.getElementById('feedbackSuccess').classList.remove('hidden');
}

// Submit feedback to server
async function submitFeedbackToServer(isCorrect, actualResult, feedbackNotes) {
    try {
        const response = await fetch('/api/feedback', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                analysisId: currentAnalysisId,
                userId: currentUser,
                isCorrect: isCorrect,
                actualResult: actualResult,
                feedbackNotes: feedbackNotes
            })
        });
        
        const data = await response.json();
        
        if (!data.success) {
            console.error('Geri bildirim gönderme hatası:', data.error);
        }
    } catch (error) {
        console.error('Geri bildirim gönderme hatası:', error);
    }
}

// Show loading modal
function showLoading() {
    document.getElementById('loadingModal').classList.remove('hidden');
}

// Hide loading modal
function hideLoading() {
    document.getElementById('loadingModal').classList.add('hidden');
}

// Show result
function showResult(analysis) {
    document.getElementById('analysisContent').textContent = analysis;
    document.getElementById('result').classList.remove('hidden');
    document.getElementById('result').scrollIntoView({ behavior: 'smooth' });
    
    // Reset feedback section
    document.getElementById('feedbackForm').classList.add('hidden');
    document.getElementById('feedbackSuccess').classList.add('hidden');
}

// Hide result
function hideResult() {
    document.getElementById('result').classList.add('hidden');
    currentAnalysisId = null;
    currentAnalysisData = null;
}

// Reset forms
function resetForms() {
    // Reset file form
    const fileInput = document.getElementById('fileInput');
    fileInput.value = '';
    const dropZone = document.getElementById('dropZone');
    dropZone.querySelector('p').textContent = '📁 Dosyayı buraya sürükleyin veya tıklayın';
    
    // Reset text form
    document.getElementById('textInput').value = '';
    
    // Hide results
    hideResult();
    
    // Reset to file tab
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.querySelector('[data-tab="file"]').classList.add('active');
    document.getElementById('fileTab').classList.add('active');
}