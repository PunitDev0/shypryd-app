import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class RaiseTicketScreen extends StatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends State<RaiseTicketScreen> {
  static const Color yellow = Color(0xFFFFD600);
  static const Color borderColor = Color(0xFFBDBDBD);

  final List<String> problemTypes = [
    'Vehicle Problem',
    'Payment Problem',
    'Battery Problem',
    'File Complaint',
    'App Problem',
    'Other Problem',
  ];

  String? selectedProblemType;
  String? description;
  String? voiceNotePath; // local file path of recorded audio
  bool isRecording = false;
  bool isPlaying = false;
  bool isSubmitting = false;

  final List<XFile?> images = [null, null, null]; // 3 fixed slots

  final TextEditingController _descController = TextEditingController();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _descController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.microphone,
      Permission.camera,
      Permission.photos,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Some permissions are required.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
    }

    return allGranted;
  }

  // ────────────────────────────────────────────────
  // UI Build
  // ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Create Support Ticket',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Problem Type'),
                const SizedBox(height: 8),
                _dropdownField(),
                const SizedBox(height: 24),
                _label('Describe Your Issue (Optional)'),
                const SizedBox(height: 8),
                _descriptionField(),
                const SizedBox(height: 24),
                _label('Voice Recording (Optional)'),
                const SizedBox(height: 8),
                _voiceRecordingCard(),
                const SizedBox(height: 24),
                _label('Attach Images (Max 3)'),
                const SizedBox(height: 8),
                _imageSlots(),
                const SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed:
                      _canSubmit() && !isSubmitting ? _submitTicket : null,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Submit',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _dropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedProblemType,
          hint: const Text('Select problem type',
              style: TextStyle(color: Colors.black54)),
          isExpanded: true,
          items: problemTypes
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (val) => setState(() => selectedProblemType = val),
        ),
      ),
    );
  }

  Widget _descriptionField() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _descController,
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          hintText: 'Please explain your issue in detail...\n(Optional)',
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _voiceRecordingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.mic, color: Colors.black),
              const SizedBox(width: 8),
              const Text('Voice Recording',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          if (!isRecording && voiceNotePath == null)
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                height: 80,
                width: 80,
                decoration:
                    const BoxDecoration(color: yellow, shape: BoxShape.circle),
                child: const Icon(Icons.mic, size: 36, color: Colors.black),
              ),
            )
          else if (isRecording)
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.stop, size: 36, color: Colors.white),
              ),
            )
          else ...[
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 48,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36),
                  color: Colors.black,
                  onPressed: _playVoiceNote,
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.delete_forever,
                      size: 36, color: Colors.red),
                  onPressed: () => setState(() => voiceNotePath = null),
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon:
                      const Icon(Icons.refresh, size: 36, color: Colors.black),
                  onPressed: _startRecording,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            isRecording
                ? 'Recording... Tap to stop'
                : (voiceNotePath != null
                    ? (isPlaying
                        ? 'Playing...'
                        : 'Voice note recorded – tap play to listen')
                    : 'Tap microphone to start recording'),
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _imageSlots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        final file = (index < images.length) ? images[index] : null;

        return GestureDetector(
          onTap: () => _pickImage(index),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: file == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 32, color: Colors.black54),
                          SizedBox(height: 4),
                          Text('Add',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
              ),
              if (file != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => images[index] = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ────────────────────────────────────────────────
  // Actions
  // ────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
      setState(() {
        isRecording = true;
        voiceNotePath = null;
        isPlaying = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
      voiceNotePath = path;
      isPlaying = false;
    });
  }

  Future<void> _playVoiceNote() async {
    if (voiceNotePath == null) return;

    try {
      if (await _player.isPlaying) {
        await _player.stopPlayer();
        setState(() => isPlaying = false);
      } else {
        await _player.startPlayer(
          fromURI: voiceNotePath,
          whenFinished: () {
            setState(() => isPlaying = false);
          },
        );
        setState(() => isPlaying = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playback error: $e')),
      );
    }
  }

  Future<void> _pickImage(int slotIndex) async {
    final granted = await _requestPermissions();
    if (!granted) return;

    final picker = ImagePicker();
    final source = await showDialog<ImageSource?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose source'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera')),
          TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery')),
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel')),
        ],
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        images[slotIndex] = picked;
      });
    }
  }

  bool _canSubmit() {
    return selectedProblemType != null && !isRecording && !isSubmitting;
  }

  Future<void> _submitTicket() async {
    setState(() => isSubmitting = true);

    try {
      print('=== Starting ticket submission ===');

      final token = await _storage.read(key: 'auth_token');
      print(
          'Retrieved token: ${token != null ? token.substring(0, 20) + "..." : "NULL - no token found"}');

      if (token == null) {
        print('ERROR: No auth token found in secure storage');
        throw Exception('No auth token found. Please login again.');
      }

      final uri = Uri.parse('http://192.168.1.43:5008/api/ticket/raise');
      print('API Endpoint: $uri');
      print('Problem Type: $selectedProblemType');
      print('Description length: ${_descController.text.trim().length} chars');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      print(
          'Headers set: Authorization Bearer (token length: ${token.length})');

      // Fields
      request.fields['problemType'] = selectedProblemType ?? '';
      request.fields['description'] = _descController.text.trim();
      print('Added fields: problemType & description');

      // Voice file
      if (voiceNotePath != null && File(voiceNotePath!).existsSync()) {
        final voiceFile = File(voiceNotePath!);
        print(
            'Adding voice file: ${voiceFile.path} (size: ${await voiceFile.length()} bytes)');
        request.files.add(
          await http.MultipartFile.fromPath(
            'voice',
            voiceFile.path,
            contentType: MediaType('audio', 'aac'),
          ),
        );
      } else {
        print('No voice note attached');
      }

      // Attachments (images)
      int imageCount = 0;
      for (final image in images.whereType<XFile>()) {
        final file = File(image.path);
        if (await file.exists()) {
          print(
              'Adding image ${imageCount + 1}: ${file.path} (size: ${await file.length()} bytes)');
          request.files.add(
            await http.MultipartFile.fromPath(
              'attachments',
              file.path,
              contentType: MediaType('image', image.path.split('.').last),
            ),
          );
          imageCount++;
        }
      }
      print('Total images attached: $imageCount');

      print('Sending multipart request...');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('API Response - Status: ${response.statusCode}');
      print('API Response - Headers: ${response.headers}');
      print('API Response - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('SUCCESS: Ticket raised successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket raised successfully!')),
        );

        // Optional: clear form after success
        setState(() {
          selectedProblemType = null;
          _descController.clear();
          voiceNotePath = null;
          images.fillRange(0, 3, null);
        });

        Navigator.pop(context); // or go to ticket list / success screen
      } else {
        String msg = 'Failed to raise ticket: ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          msg = data['message'] ?? data['error'] ?? msg;
          print('Parsed error message from backend: $msg');
        } catch (e) {
          print('Could not parse JSON response: $e');
        }
        print('ERROR: Submission failed with message: $msg');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e, stack) {
      print('EXCEPTION in _submitTicket: $e');
      print('Stack trace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      print('=== Ticket submission finished ===');
      setState(() => isSubmitting = false);
    }
  }
}
