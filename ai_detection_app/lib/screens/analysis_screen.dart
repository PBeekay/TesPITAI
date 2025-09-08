import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/analysis_result_widget.dart';
import '../widgets/feedback_widget.dart';
import '../widgets/loading_overlay.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  XFile? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, child) {
        return LoadingOverlay(
          isLoading: analysisProvider.isLoading,
          message: 'AI analizi yapılıyor...',
          child: Scaffold(
            body: Column(
              children: [
                // Tab bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF667eea),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF667eea),
                    tabs: const [
                      Tab(icon: Icon(Icons.text_fields), text: 'Metin Analizi'),
                      Tab(icon: Icon(Icons.attach_file), text: 'Dosya Analizi'),
                      Tab(icon: Icon(Icons.image), text: 'Resim Analizi'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTextAnalysisTab(),
                      _buildFileAnalysisTab(),
                      _buildImageAnalysisTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Metin girişi
          Expanded(
            flex: 2,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metin Girişi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText:
                              'Analiz etmek istediğiniz metni buraya yazın...',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Karakter sayısı: ${_textController.text.length}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buton durumu: ${_textController.text.trim().isEmpty ? "Disabled" : "Enabled"}',
                          style: TextStyle(
                            color: _textController.text.trim().isEmpty
                                ? Colors.red
                                : Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Consumer<AnalysisProvider>(
                          builder: (context, analysisProvider, child) {
                            return ElevatedButton.icon(
                              onPressed: analysisProvider.isLoading
                                  ? null
                                  : () {
                                      if (_textController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Lütfen analiz etmek için bir metin girin',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                      _analyzeText();
                                    },
                              icon: analysisProvider.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.psychology),
                              label: Text(
                                analysisProvider.isLoading
                                    ? 'Analiz Ediliyor...'
                                    : 'Analiz Et',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Analiz sonucu
          Consumer<AnalysisProvider>(
            builder: (context, analysisProvider, child) {
              if (analysisProvider.currentAnalysis != null) {
                return Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AnalysisResultWidget(
                          result: analysisProvider.currentAnalysis!,
                        ),
                        const SizedBox(height: 16),
                        if (analysisProvider.currentAnalysis!.analysisId !=
                            null)
                          FeedbackWidget(
                            analysisId:
                                analysisProvider.currentAnalysis!.analysisId!,
                            aiDetected:
                                analysisProvider.currentAnalysis!.aiDetected,
                          ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Dosya seçimi
          Expanded(
            flex: 2,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload,
                      size: 80,
                      color: Color(0xFF667eea),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dosya Seçin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final canUploadFiles =
                            authProvider.user?.canUploadFile() ?? false;
                        return Column(
                          children: [
                            Text(
                              canUploadFiles
                                  ? 'PDF, DOC, DOCX, TXT dosyalarını ve resimleri yükleyebilirsiniz'
                                  : 'Dosya yükleme özelliği kilitli',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: canUploadFiles
                                    ? Colors.grey
                                    : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            if (!canUploadFiles) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Premium özellik',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    if (_selectedFileName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedFileName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFileName = null;
                                  _selectedFilePath = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Consumer2<AnalysisProvider, AuthProvider>(
                      builder:
                          (context, analysisProvider, authProvider, child) {
                            final canUploadFiles =
                                authProvider.user?.canUploadFile() ?? false;
                            final isDisabled =
                                analysisProvider.isLoading || !canUploadFiles;

                            return ElevatedButton.icon(
                              onPressed: isDisabled ? null : _pickFile,
                              icon: canUploadFiles
                                  ? const Icon(Icons.folder_open)
                                  : const Icon(Icons.lock),
                              label: Text(
                                !canUploadFiles
                                    ? 'Kilitli - Premium Gerekli'
                                    : (_selectedFileName != null
                                          ? 'Dosya Değiştir'
                                          : 'Dosya Seç'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canUploadFiles
                                    ? const Color(0xFF667eea)
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                    ),

                    if (_selectedFilePath != null) ...[
                      const SizedBox(height: 16),
                      Consumer<AnalysisProvider>(
                        builder: (context, analysisProvider, child) {
                          return ElevatedButton.icon(
                            onPressed: analysisProvider.isLoading
                                ? null
                                : () => _analyzeFile(),
                            icon: analysisProvider.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.psychology),
                            label: Text(
                              analysisProvider.isLoading
                                  ? 'Analiz Ediliyor...'
                                  : 'Analiz Et',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Analiz sonucu
          Consumer<AnalysisProvider>(
            builder: (context, analysisProvider, child) {
              if (analysisProvider.currentAnalysis != null) {
                return Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AnalysisResultWidget(
                          result: analysisProvider.currentAnalysis!,
                        ),
                        const SizedBox(height: 16),
                        if (analysisProvider.currentAnalysis!.analysisId !=
                            null)
                          FeedbackWidget(
                            analysisId:
                                analysisProvider.currentAnalysis!.analysisId!,
                            aiDetected:
                                analysisProvider.currentAnalysis!.aiDetected,
                          ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'jpg',
          'jpeg',
          'png',
          'gif',
        ],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dosya seçme hatası: $e')));
      }
    }
  }

  Future<void> _analyzeText() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analysisProvider = Provider.of<AnalysisProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) {
      return;
    }

    final wordCount = _textController.text.trim().split(RegExp(r'\s+')).length;

    // Check if user can analyze this text
    if (!authProvider.user!.canAnalyzeText(wordCount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Günlük kelime limitinizi aştınız. Mevcut limit: ${authProvider.user!.subscription.wordLimit} kelime',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await analysisProvider.analyzeText(
      _textController.text.trim(),
      authProvider.user!.username,
    );

    if (success) {
      // Update user usage
      final updatedUser = authProvider.user!.updateUsage(wordCount: wordCount);
      authProvider.updateUser(updatedUser);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(analysisProvider.error ?? 'Analiz başarısız'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeFile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analysisProvider = Provider.of<AnalysisProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null || _selectedFilePath == null) return;

    // Check if user can upload files
    if (!authProvider.user!.canUploadFile()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Günlük dosya yükleme limitinizi aştınız. Mevcut limit: ${authProvider.user!.subscription.fileUploadLimit} dosya',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await analysisProvider.analyzeFile(
      _selectedFilePath!,
      authProvider.user!.username,
    );

    if (success) {
      // Update user usage
      final updatedUser = authProvider.user!.updateUsage(fileUploaded: true);
      authProvider.updateUser(updatedUser);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(analysisProvider.error ?? 'Analiz başarısız'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImageAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Resim seçimi
          Expanded(
            flex: 2,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 80, color: Color(0xFF667eea)),
                    const SizedBox(height: 16),
                    const Text(
                      'Resim Seçin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final canUploadImages =
                            authProvider.user?.canUploadImage() ?? false;
                        return Column(
                          children: [
                            Text(
                              canUploadImages
                                  ? 'JPG, PNG, GIF formatındaki resimleri yükleyebilirsiniz'
                                  : 'Resim yükleme özelliği kilitli',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: canUploadImages
                                    ? Colors.grey
                                    : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            if (!canUploadImages) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Premium özellik',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    if (_selectedImage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedImage!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Consumer2<AnalysisProvider, AuthProvider>(
                      builder:
                          (context, analysisProvider, authProvider, child) {
                            final canUploadImages =
                                authProvider.user?.canUploadImage() ?? false;
                            final isDisabled =
                                analysisProvider.isLoading || !canUploadImages;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: isDisabled
                                      ? null
                                      : () => _pickImageFromCamera(),
                                  icon: canUploadImages
                                      ? const Icon(Icons.camera_alt)
                                      : const Icon(Icons.lock),
                                  label: Text(
                                    canUploadImages ? 'Kamera' : 'Kilitli',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canUploadImages
                                        ? const Color(0xFF667eea)
                                        : Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: isDisabled
                                      ? null
                                      : () => _pickImageFromGallery(),
                                  icon: canUploadImages
                                      ? const Icon(Icons.photo_library)
                                      : const Icon(Icons.lock),
                                  label: Text(
                                    canUploadImages ? 'Galeri' : 'Kilitli',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canUploadImages
                                        ? const Color(0xFF667eea)
                                        : Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                    ),

                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      Consumer<AnalysisProvider>(
                        builder: (context, analysisProvider, child) {
                          return ElevatedButton.icon(
                            onPressed: analysisProvider.isLoading
                                ? null
                                : () => _analyzeImage(),
                            icon: analysisProvider.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.psychology),
                            label: Text(
                              analysisProvider.isLoading
                                  ? 'Analiz Ediliyor...'
                                  : 'Analiz Et',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Analiz sonucu
          Consumer<AnalysisProvider>(
            builder: (context, analysisProvider, child) {
              if (analysisProvider.currentAnalysis != null) {
                return Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AnalysisResultWidget(
                          result: analysisProvider.currentAnalysis!,
                        ),
                        const SizedBox(height: 16),
                        if (analysisProvider.currentAnalysis!.analysisId !=
                            null)
                          FeedbackWidget(
                            analysisId:
                                analysisProvider.currentAnalysis!.analysisId!,
                            aiDetected:
                                analysisProvider.currentAnalysis!.aiDetected,
                          ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kamera hatası: $e')));
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Galeri hatası: $e')));
      }
    }
  }

  Future<void> _analyzeImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analysisProvider = Provider.of<AnalysisProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null || _selectedImage == null) return;

    // Check if user can upload images
    if (!authProvider.user!.canUploadImage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resim yükleme özelliği aboneliğinizde mevcut değil'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if user can upload files
    if (!authProvider.user!.canUploadFile()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Günlük dosya yükleme limitinizi aştınız. Mevcut limit: ${authProvider.user!.subscription.fileUploadLimit} dosya',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await analysisProvider.analyzeImage(
      _selectedImage!,
      authProvider.user!.username,
    );

    if (success) {
      // Update user usage
      final updatedUser = authProvider.user!.updateUsage(fileUploaded: true);
      authProvider.updateUser(updatedUser);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(analysisProvider.error ?? 'Analiz başarısız'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
