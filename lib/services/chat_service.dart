import '../models/message.dart';

class ChatService {
  Future<ChatMessage> sendMessage({
    required String fromUserId,
    required String toUserId,
    required bool isFromDietitian,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: fromUserId,
      toUserId: toUserId,
      text: text,
      timestamp: DateTime.now(),
      isFromDietitian: isFromDietitian,
    );
  }
}
