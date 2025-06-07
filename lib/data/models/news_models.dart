import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModels {
  final String uid;
  final String tenBaiViet;
  final String? noiDungBaiViet;
  final String? fileDinhKem;
  final String? duongDan;
  final String? chuDe;
  final DateTime createAt;
  final String? tacGia; // THÊM MỚI: Tên tác giả

  const NewsModels({
    required this.uid,
    required this.tenBaiViet,
    this.noiDungBaiViet,
    this.fileDinhKem,
    this.duongDan,
    this.chuDe,
    required this.createAt,
    this.tacGia, // THÊM MỚI
  });

  static NewsModels empty = NewsModels(uid: '', tenBaiViet: '', createAt: DateTime(0));
  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  factory NewsModels.fromJson(Map<String, dynamic> json, String documentId) {
    return NewsModels(
      uid: documentId,
      tenBaiViet: json['tenBaiViet'] as String? ?? '',
      noiDungBaiViet: json['noiDungBaiViet'] as String?,
      fileDinhKem: json['fileDinhKem'] as String?,
      duongDan: json['duongDan'] as String?,
      chuDe: json['chuDe'] as String?,
      createAt: (json['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tacGia: json['tacGia'] as String?, // THÊM MỚI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenBaiViet': tenBaiViet,
      'noiDungBaiViet': noiDungBaiViet,
      'fileDinhKem': fileDinhKem,
      'duongDan': duongDan,
      'chuDe': chuDe,
      'createAt': Timestamp.fromDate(createAt),
      'tacGia': tacGia, // THÊM MỚI
    };
  }

  NewsModels copyWith({
    String? uid,
    String? tenBaiViet,
    String? noiDungBaiViet,
    String? fileDinhKem,
    String? duongDan,
    String? chuDe,
    DateTime? createAt,
    String? tacGia, // THÊM MỚI
  }) {
    return NewsModels(
      uid: uid ?? this.uid,
      tenBaiViet: tenBaiViet ?? this.tenBaiViet,
      noiDungBaiViet: noiDungBaiViet ?? this.noiDungBaiViet,
      fileDinhKem: fileDinhKem ?? this.fileDinhKem,
      duongDan: duongDan ?? this.duongDan,
      chuDe: chuDe ?? this.chuDe,
      createAt: createAt ?? this.createAt,
      tacGia: tacGia ?? this.tacGia, // THÊM MỚI
    );
  }
}
