import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import '../providers/document_provider.dart';
import '../models/document.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadError;
  static const _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const _allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/heic',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<DocumentProvider>().loadAllDocuments()
    );
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      setState(() {
        _uploadError = null;
        _isUploading = true;
      });

      // Show document source options
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Document Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                subtitle: const Text('Upload from your photo library'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Files'),
                subtitle: const Text('Upload from your device storage'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        ),
      );

      if (source == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Pick image
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      await _processAndUploadFile(File(pickedFile.path));
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to upload document: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_uploadError!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickFile() async {
    // TODO: Implement file picker for non-image files
    // This will require platform-specific implementation
    // For now, we'll show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File picker will be implemented soon'),
        ),
      );
    }
  }

  Future<void> _processAndUploadFile(File file) async {
    // Validate file size
    final fileSize = await file.length();
    if (fileSize > _maxFileSize) {
      setState(() {
        _uploadError = 'File size must be less than 10MB';
        _isUploading = false;
      });
      return;
    }

    // Validate file type
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || !_allowedMimeTypes.contains(mimeType)) {
      setState(() {
        _uploadError = 'File type not supported';
        _isUploading = false;
      });
      return;
    }

    // Show document details dialog
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _DocumentDetailsDialog(
        fileName: path.basename(file.path),
        fileType: mimeType,
      ),
    );

    if (result == null) {
      setState(() => _isUploading = false);
      return;
    }

    // Generate a secure filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(file.path);
    final filename = '${timestamp}_${path.basename(file.path)}';
    
    // Create a secure storage reference
    final storageRef = _storage
        .ref()
        .child('documents')
        .child(filename);

    // Upload with metadata
    final metadata = SettableMetadata(
      contentType: mimeType,
      customMetadata: {
        'uploadedAt': DateTime.now().toIso8601String(),
        'originalFilename': path.basename(file.path),
        'documentType': result['type']!,
        'description': result['description']!,
      },
    );

    // Upload file with progress tracking
    final uploadTask = storageRef.putFile(file, metadata);
    
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading: ${(progress * 100).toStringAsFixed(1)}%'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });

    // Wait for upload to complete
    await uploadTask;
    
    // Get download URL
    final downloadUrl = await storageRef.getDownloadURL();

    // Create and save document record
    final doc = Document(
      id: null,
      tripId: 0, // Global document, not associated with a trip
      type: result['type']!,
      filePath: downloadUrl,
      description: result['description']!,
    );

    await context.read<DocumentProvider>().addDocument(doc);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _isUploading ? null : _pickAndUploadDocument,
            tooltip: 'Upload Document',
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = provider.documents;
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No documents yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the upload button to add your first document',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadDocument,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Document'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final isImage = doc.mimeType?.startsWith('image/') ?? false;
              
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _viewDocument(doc),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isImage)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: FutureBuilder<bool>(
                            future: File(doc.filePath).exists(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (snapshot.data == true) {
                                return Image.file(
                                  File(doc.filePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.error_outline, color: Colors.red),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              _getDocumentIcon(doc.filePath),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.type,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (doc.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      doc.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Uploaded ${_formatDate(doc.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDocument(doc),
                              tooltip: 'Delete Document',
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => _viewDocument(doc),
                              tooltip: 'Open Document',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadDocument,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }

  IconData _getDocumentIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.heic':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  Future<void> _downloadDocument(Document doc) async {
    // TODO: Implement document download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download will be implemented soon')),
    );
  }

  Future<void> _viewDocument(Document doc) async {
    try {
      // Ensure we have a valid file path
      String filePath = doc.filePath;
      if (filePath.startsWith('file://')) {
        filePath = Uri.parse(filePath).toFilePath();
      }
      
      final file = File(filePath);
      if (!await file.exists()) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('File Not Found'),
              content: const Text('The document file could not be found on your device.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final isImage = doc.mimeType?.startsWith('image/') ?? false;
      
      if (isImage) {
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.file(
                        file,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.error_outline, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.type,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (doc.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(doc.description),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Uploaded ${_formatDate(doc.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // For non-image documents
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(_getDocumentIcon(doc.filePath)),
                const SizedBox(width: 8),
                Expanded(child: Text(doc.type)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (doc.description.isNotEmpty) ...[
                  Text(doc.description),
                  const SizedBox(height: 16),
                ],
                Text(
                  'File: ${path.basename(doc.filePath)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Uploaded ${_formatDate(doc.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await OpenFile.open(filePath);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to open file: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open File'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error viewing document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDocument(Document doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Delete the file from storage
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        // Remove from database
        await context.read<DocumentProvider>().deleteDocument(doc.id!, doc.tripId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete document: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _DocumentDetailsDialog extends StatefulWidget {
  final String fileName;
  final String fileType;

  const _DocumentDetailsDialog({
    required this.fileName,
    required this.fileType,
  });

  @override
  State<_DocumentDetailsDialog> createState() => _DocumentDetailsDialogState();
}

class _DocumentDetailsDialogState extends State<_DocumentDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Document Details'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Document Type',
                hintText: 'e.g., Receipt, Invoice, Contract',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Please enter a document type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Add any additional details',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, {
                'type': _typeController.text,
                'description': _descriptionController.text,
              });
            }
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
} 