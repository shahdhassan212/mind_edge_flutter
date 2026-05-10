class ChatRequestModel {
  final String question;
  final String? sessionId;
  final bool tts;

  ChatRequestModel({
    required this.question,
    this.sessionId,
    required this.tts,
  });

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "sessionId": sessionId,
      "tts": tts,
    };
  }
}

class ChatResponseModel {
  final String answer;
  final String? audioUrl;
  final String sessionId;

  ChatResponseModel({
    required this.answer,
    required this.sessionId,
    this.audioUrl,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      answer: json["answer"] ?? "",
      audioUrl: json["audio_url"],
      sessionId: json["session_id"] ?? "",
    );
  }
}
