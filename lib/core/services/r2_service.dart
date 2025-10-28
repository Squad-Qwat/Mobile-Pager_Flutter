import 'dart:typed_data';
import 'package:cloudflare_r2/cloudflare_r2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for uploading images to Cloudflare R2
class R2Service {
  static final R2Service _instance = R2Service._internal();
  factory R2Service() => _instance;
  R2Service._internal();

  bool _initialized = false;
  late String _bucketName;
  late String _accountId;

  /// Initialize the R2 service with credentials from .env
  Future<void> initialize() async {
    if (_initialized) return;

    _accountId = dotenv.env['CLOUDFLARE_ACCOUNT_ID'] ?? '';
    final accessKeyId = dotenv.env['CLOUDFLARE_ACCESS_KEY_ID'] ?? '';
    final secretAccessKey = dotenv.env['CLOUDFLARE_SECRET_ACCESS_KEY'] ?? '';
    _bucketName = dotenv.env['CLOUDFLARE_BUCKET_NAME'] ?? '';

    if (_accountId.isEmpty || accessKeyId.isEmpty || secretAccessKey.isEmpty || _bucketName.isEmpty) {
      throw Exception('Missing Cloudflare R2 credentials in .env file');
    }

    CloudFlareR2.init(
      accountId: _accountId,
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
    );

    _initialized = true;
  }

  /// Upload an image to R2 and return the public URL
  /// [imageBytes] - The image data as bytes
  /// [fileName] - Optional custom filename, will generate unique name if not provided
  Future<String> uploadImage(Uint8List imageBytes, {String? fileName}) async {
    if (!_initialized) {
      await initialize();
    }

    // Generate unique filename if not provided
    final name = fileName ?? 'pager_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload to R2
    await CloudFlareR2.putObject(
      bucket: _bucketName,
      objectName: name,
      objectBytes: imageBytes,
      contentType: 'image/jpeg',
    );

    // Generate presigned URL for accessing the image (valid for 7 days)
    final url = await CloudFlareR2.getPresignedUrl(
      bucket: _bucketName,
      objectName: name,
      expiresIn: const Duration(days: 7),
    );

    return url;
  }

  /// Delete an image from R2
  Future<void> deleteImage(String objectName) async {
    if (!_initialized) {
      await initialize();
    }

    await CloudFlareR2.deleteObject(
      bucket: _bucketName,
      objectName: objectName,
    );
  }
}
