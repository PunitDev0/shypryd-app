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
import 'package:Maxryd_app/core/constants/api_constants.dart';

class RaiseTicketScreen extends StatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends State<RaiseTicketScreen> {
  static const Color yellow = Color(0xFFf5c034);
  static const Color darkBg = Colors.black;
  static const Color darkCard = Color(0xFF1E1E1E);

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
  String? voiceNotePath; 
  bool isRecording = false;
  bool isPlaying = false;
  bool isSubmitting = false;

  final List<XFile?> images = [null, null, null];

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
          content: const Text('Permissions are required to attach media.'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: openAppSettings,
          ),
        ),
      );
    }

    return allGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: yellow),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Raise Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Problem Type'),
                const SizedBox(height: 12),
                _dropdownField(),
                const SizedBox(height: 30),
                _label('Description (Optional)'),
                const SizedBox(height: 12),
                _descriptionField(),
                const SizedBox(height: 30),
                _label('Voice Note (Optional)'),
                const SizedBox(height: 12),
                _voiceRecordingCard(),
                const SizedBox(height: 30),
                _label('Attachments (Max 3)'),
                const SizedBox(height: 12),
                _imageSlots(),
                const SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
              decoration: BoxDecoration(
                color: darkBg,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 60),
                    elevation: 8,
                    shadowColor: yellow.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                  ),
                  onPressed: _canSubmit() && !isSubmitting ? _submitTicket : null,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Submit Ticket',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
    );
  }

  Widget _dropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 65,
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedProblemType,
          dropdownColor: darkCard,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: yellow),
          hint: const Text('Select issue type',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _descController,
        maxLines: null,
        expands: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Describe your problem here...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _voiceRecordingCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          if (!isRecording && voiceNotePath == null)
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: yellow.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: yellow.withOpacity(0.2)),
                ),
                child: const Icon(Icons.mic_none_rounded, size: 40, color: yellow),
              ),
            )
          else if (isRecording)
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: const Icon(Icons.stop_rounded, size: 40, color: Colors.redAccent),
              ),
            )
          else ...[
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                        size: 40, color: yellow),
                    onPressed: _playVoiceNote,
                  ),
                  const SizedBox(width: 20),
                  const Text("Voice Recorded", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () => setState(() => voiceNotePath = null),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 15),
          Text(
            isRecording
                ? 'Recording in progress...'
                : (voiceNotePath != null
                    ? 'Audio note attached'
                    : 'Tap to record a voice message'),
            style: TextStyle(color: isRecording ? Colors.redAccent : Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _imageSlots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        final file = (index < images.length) ? images[index] : null;

        return GestureDetector(
          onTap: () => _pickImage(index),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (file == null)
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, size: 30, color: yellow),
                      SizedBox(height: 5),
                      Text('Add', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(file.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (file != null)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => setState(() => images[index] = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
      setState(() {
        isRecording = true;
        voiceNotePath = null;
        isPlaying = false;
      });
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
    if (await _player.isPlaying) {
      await _player.stopPlayer();
      setState(() => isPlaying = false);
    } else {
      await _player.startPlayer(
        fromURI: voiceNotePath,
        whenFinished: () => setState(() => isPlaying = false),
      );
      setState(() => isPlaying = true);
    }
  }

  Future<void> _pickImage(int slotIndex) async {
    final granted = await _requestPermissions();
    if (!granted) return;

    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Source", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.camera_rounded, color: yellow),
              title: const Text("Camera", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: yellow),
              title: const Text("Gallery", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() => images[slotIndex] = picked);
      }
    }
  }

  bool _canSubmit() {
    return selectedProblemType != null && !isRecording && !isSubmitting;
  }

  Future<void> _submitTicket() async {
    setState(() => isSubmitting = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found.');

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/ticket/raise');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['problemType'] = selectedProblemType ?? '';
      request.fields['description'] = _descController.text.trim();

      if (voiceNotePath != null && File(voiceNotePath!).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('voice', voiceNotePath!, contentType: MediaType('audio', 'aac')));
      }

      for (final image in images.whereType<XFile>()) {
        request.files.add(await http.MultipartFile.fromPath('attachments', image.path, contentType: MediaType('image', image.path.split('.').last)));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket raised successfully!'), backgroundColor: Colors.greenAccent));
        Navigator.pop(context);
      } else {
        throw Exception('Failed to raise ticket');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}
