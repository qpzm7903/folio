import 'package:flutter/foundation.dart';

/// 一条金句 —— 单机, 不可变, 用 JSON 持久化。
@immutable
class Quote {
  const Quote({
    required this.id,
    required this.text,
    required this.tag,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String tag;
  final DateTime createdAt;

  Quote copyWith({String? id, String? text, String? tag, DateTime? createdAt}) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': text,
    'tag': tag,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      tag: (json['tag'] as String?) ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quote &&
          other.id == id &&
          other.text == text &&
          other.tag == tag &&
          other.createdAt == createdAt);

  @override
  int get hashCode => Object.hash(id, text, tag, createdAt);
}
