class RockModels {
  final String uid;
  final List<String> hinhAnh; // SỬA: Không cho phép null, mặc định là list rỗng x
  final String? tenDa;
  final String? loaiDa;
  final String? thanhPhanHoaHoc;
  final String? doCung;
  final String? mauSac;
  final List<String> cauHoi;
  final List<String> traLoi;
  final String? mieuTa;
  final String? dacDiem;
  final String? nhomDa;
  final String? matDo;
  final String? kienTruc;
  final String? cauTao;
  final String? thanhPhanKhoangSan;
  final String? congDung;
  final String? noiPhanBo;
  final String? motSoKhoangSanLienQuan;
  final String? nhanhDa;
  final String? tenTiengViet;

  const RockModels({
    required this.uid,
    this.hinhAnh = const [], // SỬA: Gán giá trị mặc định
    this.tenDa,
    this.loaiDa,
    this.thanhPhanHoaHoc,
    this.doCung,
    this.mauSac,
    this.cauHoi = const [], // SỬA: Gán giá trị mặc định
    this.traLoi = const [], // SỬA: Gán giá trị mặc định
    this.mieuTa,
    this.dacDiem,
    this.nhomDa,
    this.matDo,
    this.kienTruc,
    this.cauTao,
    this.thanhPhanKhoangSan,
    this.congDung,
    this.noiPhanBo,
    this.motSoKhoangSanLienQuan,
    this.nhanhDa,
    this.tenTiengViet,
  });

  // THÊM: Các phương thức tiện ích
  static const RockModels empty = RockModels(uid: '');
  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  factory RockModels.fromJson(Map<String, dynamic> json) {
    return RockModels(
        uid: json['uid'] as String? ?? '',
        hinhAnh: List<String>.from(json['hinhAnh'] ?? []),
        tenDa: json['tenDa'] as String?,
        loaiDa: json['loaiDa'] as String?,
        thanhPhanHoaHoc: json['thanhPhanHoaHoc'] as String?,
        doCung: json['doCung'] as String?,
        mauSac: json['mauSac'] as String?,
        cauHoi: List<String>.from(json['cauHoi'] ?? []),
        traLoi: List<String>.from(json['traLoi'] ?? []),
        mieuTa: json['mieuTa'] as String?,
        dacDiem: json['dacDiem'] as String?,
        nhomDa: json['nhomDa'] as String?,
        matDo: json['matDo'] as String?,
        kienTruc: json['kienTruc'] as String?,
        cauTao: json['cauTao'] as String?,
        thanhPhanKhoangSan: json['thanhPhanKhoangSan'] as String?,
        congDung: json['congDung'] as String?,
        noiPhanBo: json['noiPhanBo'] as String?,
        motSoKhoangSanLienQuan: json['motSoKhoangSanLienQuan'] as String?,
        tenTiengViet: json['tenTiengViet'] as String?,
        nhanhDa: json['nhanhDa'] as String?);
  }

  Map<String, dynamic> toJson() {
    // SỬA: Không cần lưu uid trong data vì nó là ID của document
    return {
      'hinhAnh': hinhAnh,
      'tenDa': tenDa,
      'loaiDa': loaiDa,
      'thanhPhanHoaHoc': thanhPhanHoaHoc,
      'doCung': doCung,
      'mauSac': mauSac,
      'cauHoi': cauHoi,
      'traLoi': traLoi,
      'mieuTa': mieuTa,
      'dacDiem': dacDiem,
      'nhomDa': nhomDa,
      'matDo': matDo,
      'kienTruc': kienTruc,
      'cauTao': cauTao,
      'thanhPhanKhoangSan': thanhPhanKhoangSan,
      'congDung': congDung,
      'noiPhanBo': noiPhanBo,
      'motSoKhoangSanLienQuan': motSoKhoangSanLienQuan,
      'nhanhDa': nhanhDa,
      'tenTiengViet': tenTiengViet
    };
  }

  RockModels copyWith(
      {String? uid,
      List<String>? hinhAnh,
      String? tenDa,
      String? loaiDa,
      String? thanhPhanHoaHoc,
      String? doCung,
      String? mauSac,
      List<String>? cauHoi,
      List<String>? traLoi,
      String? mieuTa,
      String? dacDiem,
      String? nhomDa,
      String? matDo,
      String? kienTruc,
      String? cauTao,
      String? thanhPhanKhoangSan,
      String? congDung,
      String? noiPhanBo,
      String? motSoKhoangSanLienQuan,
      String? nhanhDa,
      String? tenTiengViet}) {
    return RockModels(
      uid: uid ?? this.uid,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      tenDa: tenDa ?? this.tenDa,
      loaiDa: loaiDa ?? this.loaiDa,
      thanhPhanHoaHoc: thanhPhanHoaHoc ?? this.thanhPhanHoaHoc,
      doCung: doCung ?? this.doCung,
      mauSac: mauSac ?? this.mauSac,
      cauHoi: cauHoi ?? this.cauHoi,
      traLoi: traLoi ?? this.traLoi,
      mieuTa: mieuTa ?? this.mieuTa,
      dacDiem: dacDiem ?? this.dacDiem,
      nhomDa: nhomDa ?? this.nhomDa,
      matDo: matDo ?? this.matDo,
      kienTruc: kienTruc ?? this.kienTruc,
      cauTao: cauTao ?? this.cauTao,
      thanhPhanKhoangSan: thanhPhanKhoangSan ?? this.thanhPhanKhoangSan,
      congDung: congDung ?? this.congDung,
      noiPhanBo: noiPhanBo ?? this.noiPhanBo,
      motSoKhoangSanLienQuan: motSoKhoangSanLienQuan ?? this.motSoKhoangSanLienQuan,
      tenTiengViet: tenTiengViet ?? this.tenTiengViet,
      nhanhDa: nhanhDa ?? this.nhanhDa,
    );
  }
}
