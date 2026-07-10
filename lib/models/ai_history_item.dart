class AiHistoryItem {
  AiHistoryItem({
    required this.id,
    required this.toolType,
    required this.title,
    required this.inputPreview,
    required this.outputPreview,
    required this.pointsCharged,
    required this.status,
    this.voiceName,
    this.language,
    this.createdAt,
  });

  factory AiHistoryItem.fromJson(Map<String, dynamic> json) {
    return AiHistoryItem(
      id: json['id'] as int? ?? 0,
      toolType: json['tool_type'] as String? ?? '',
      title: json['title'] as String? ?? 'AI Tool',
      inputPreview: json['input_preview'] as String? ?? '',
      outputPreview: json['output_preview'] as String? ?? '',
      pointsCharged: json['points_charged'] as int? ?? 0,
      status: json['status'] as String? ?? 'success',
      voiceName: json['voice_name'] as String?,
      language: json['language'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  final int id;
  final String toolType;
  final String title;
  final String inputPreview;
  final String outputPreview;
  final int pointsCharged;
  final String status;
  final String? voiceName;
  final String? language;
  final String? createdAt;

  String get preview {
    if (toolType == 'record_to_text') {
      return outputPreview.isNotEmpty ? outputPreview : inputPreview;
    }
    return inputPreview.isNotEmpty ? inputPreview : outputPreview;
  }
}
