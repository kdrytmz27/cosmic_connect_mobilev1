// lib/models/compatibility_report.dart (YENİ ALANLAR EKLENMİŞ NİHAİ HAL)

class CompatibilityReport {
  final int overallScore;
  // YENİ: Özet metni eklendi.
  final String summaryText;
  final AnalysisSection elementSection;
  final AnalysisSection modalitySection;
  // YENİ: Açısal uyum bölümü eklendi.
  final AnalysisSection aspectSection;
  final List<String> sharedAura;

  CompatibilityReport({
    required this.overallScore,
    required this.summaryText,
    required this.elementSection,
    required this.modalitySection,
    required this.aspectSection,
    required this.sharedAura,
  });

  factory CompatibilityReport.fromJson(Map<String, dynamic> json) =>
      CompatibilityReport(
        overallScore: json["overall_score"] ?? 0,
        // YENİ: Gelen 'summary_text' verisi parse ediliyor.
        summaryText: json["summary_text"] ?? "Uyumluluk analizi yapılamadı.",
        elementSection: AnalysisSection.fromJson(json["element_section"] ?? {}),
        modalitySection:
            AnalysisSection.fromJson(json["modality_section"] ?? {}),
        // YENİ: Gelen 'aspect_section' verisi parse ediliyor.
        aspectSection: AnalysisSection.fromJson(json["aspect_section"] ?? {}),
        sharedAura: json["shared_aura"] == null
            ? []
            : List<String>.from(json["shared_aura"].map((x) => x)),
      );
}

class AnalysisSection {
  final String title;
  final int score;
  final String text;

  AnalysisSection({
    required this.title,
    required this.score,
    required this.text,
  });

  factory AnalysisSection.fromJson(Map<String, dynamic> json) =>
      AnalysisSection(
        title: json["title"] ?? "Analiz",
        score: json["score"] ?? 0,
        text: json["text"] ?? "Detaylı bilgi bulunamadı.",
      );
}
