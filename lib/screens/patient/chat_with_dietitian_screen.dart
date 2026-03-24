import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';

class ChatWithDietitianScreen extends StatefulWidget {
  const ChatWithDietitianScreen({super.key});

  @override
  State<ChatWithDietitianScreen> createState() =>
      _ChatWithDietitianScreenState();
}

class _ChatWithDietitianScreenState extends State<ChatWithDietitianScreen> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final patient = Provider.of<PatientProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              reverse: true,
              itemCount: patient.conversation.length,
              itemBuilder: (context, index) {
                final msg = patient.conversation[
                    patient.conversation.length - 1 - index];
                final isMe =
                    msg.fromUserId == auth.currentUser?.id &&
                    !msg.isFromDietitian;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.green.shade200
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yaz...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed:
                      _sending ? null : () => _sendMessage(context),
                  icon: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(BuildContext context) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) return;

    setState(() {
      _sending = true;
    });
    await Provider.of<PatientProvider>(context, listen: false)
        .sendMessageFromPatient(
      patientId: auth.currentUser!.id,
      text: text,
    );
    _msgCtrl.clear();
    if (mounted) {
      setState(() {
        _sending = false;
      });
    }
  }
}
