import 'package:flutter/material.dart';

/// Available visual aesthetics for generated postcards
enum PostcardAestheticStyle {
  vintage,
  minimal,
  goldenHour,
  nordicFrost,
  midnightNoir,
  cyberGlow,
  botanicalPress,
  desertPostmark,
  monochromeFilm,
  coastalInk;

  String get label {
    switch (this) {
      case PostcardAestheticStyle.vintage:
        return 'Vintage Journal';
      case PostcardAestheticStyle.minimal:
        return 'Minimal Modern';
      case PostcardAestheticStyle.goldenHour:
        return 'Golden Hour';
      case PostcardAestheticStyle.nordicFrost:
        return 'Nordic Alpine';
      case PostcardAestheticStyle.midnightNoir:
        return 'Midnight Noir';
      case PostcardAestheticStyle.cyberGlow:
        return 'Cyber Glow';
      case PostcardAestheticStyle.botanicalPress:
        return 'Botanical Press';
      case PostcardAestheticStyle.desertPostmark:
        return 'Desert Postmark';
      case PostcardAestheticStyle.monochromeFilm:
        return 'Monochrome Film';
      case PostcardAestheticStyle.coastalInk:
        return 'Coastal Ink';
    }
  }

  Color getCanvasBackgroundColor(ColorScheme colors) {
    switch (this) {
      case PostcardAestheticStyle.vintage:
        return const Color(0xFFFBF9F5);
      case PostcardAestheticStyle.minimal:
        return Colors.white;
      case PostcardAestheticStyle.goldenHour:
        return const Color(0xFFFFF7ED);
      case PostcardAestheticStyle.nordicFrost:
        return const Color(0xFFEFF6F8);
      case PostcardAestheticStyle.midnightNoir:
        return const Color(0xFF16191D);
      case PostcardAestheticStyle.cyberGlow:
        return const Color(0xFF131C17);
      case PostcardAestheticStyle.botanicalPress:
        return const Color(0xFFEAF2E4);
      case PostcardAestheticStyle.desertPostmark:
        return const Color(0xFFFFF1DF);
      case PostcardAestheticStyle.monochromeFilm:
        return const Color(0xFFE7E7E5);
      case PostcardAestheticStyle.coastalInk:
        return const Color(0xFFE8F3F5);
    }
  }

  Color getCardBackgroundColor(ColorScheme colors) {
    switch (this) {
      case PostcardAestheticStyle.vintage:
        return Colors.white;
      case PostcardAestheticStyle.minimal:
        return const Color(0xFFF8FAF9);
      case PostcardAestheticStyle.goldenHour:
        return Colors.white;
      case PostcardAestheticStyle.nordicFrost:
        return Colors.white;
      case PostcardAestheticStyle.midnightNoir:
        return const Color(0xFF22262B);
      case PostcardAestheticStyle.cyberGlow:
        return const Color(0xFF1E2B23);
      case PostcardAestheticStyle.botanicalPress:
        return const Color(0xFFF8FCF2);
      case PostcardAestheticStyle.desertPostmark:
        return const Color(0xFFFFFBF5);
      case PostcardAestheticStyle.monochromeFilm:
        return const Color(0xFFF7F7F5);
      case PostcardAestheticStyle.coastalInk:
        return const Color(0xFFF8FEFF);
    }
  }

  Color getTextColor(ColorScheme colors) {
    switch (this) {
      case PostcardAestheticStyle.vintage:
      case PostcardAestheticStyle.minimal:
      case PostcardAestheticStyle.goldenHour:
      case PostcardAestheticStyle.nordicFrost:
        return const Color(0xFF181D1A);
      case PostcardAestheticStyle.midnightNoir:
      case PostcardAestheticStyle.cyberGlow:
        return const Color(0xFFF0F5F0);
      case PostcardAestheticStyle.botanicalPress:
      case PostcardAestheticStyle.desertPostmark:
      case PostcardAestheticStyle.monochromeFilm:
      case PostcardAestheticStyle.coastalInk:
        return const Color(0xFF1D2922);
    }
  }

  Color getSubtextColor(ColorScheme colors) {
    switch (this) {
      case PostcardAestheticStyle.vintage:
      case PostcardAestheticStyle.minimal:
        return const Color(0xFF6C757D);
      case PostcardAestheticStyle.goldenHour:
        return const Color(0xFF8C6D4F);
      case PostcardAestheticStyle.nordicFrost:
        return const Color(0xFF5A727A);
      case PostcardAestheticStyle.midnightNoir:
        return const Color(0xFF9AA4B2);
      case PostcardAestheticStyle.cyberGlow:
        return const Color(0xFFA5B8AC);
      case PostcardAestheticStyle.botanicalPress:
        return const Color(0xFF607D5A);
      case PostcardAestheticStyle.desertPostmark:
        return const Color(0xFF9A6A42);
      case PostcardAestheticStyle.monochromeFilm:
        return const Color(0xFF6B6B68);
      case PostcardAestheticStyle.coastalInk:
        return const Color(0xFF54757A);
    }
  }

  Color getAccentColor(ColorScheme colors) {
    switch (this) {
      case PostcardAestheticStyle.vintage:
        return colors.primary;
      case PostcardAestheticStyle.minimal:
        return const Color(0xFF2B303A);
      case PostcardAestheticStyle.goldenHour:
        return const Color(0xFFD97706);
      case PostcardAestheticStyle.nordicFrost:
        return const Color(0xFF1E5E5A);
      case PostcardAestheticStyle.midnightNoir:
        return const Color(0xFFE2E8F0);
      case PostcardAestheticStyle.cyberGlow:
        return const Color(0xFF38B000);
      case PostcardAestheticStyle.botanicalPress:
        return const Color(0xFF4F7A45);
      case PostcardAestheticStyle.desertPostmark:
        return const Color(0xFFC46D32);
      case PostcardAestheticStyle.monochromeFilm:
        return const Color(0xFF343A40);
      case PostcardAestheticStyle.coastalInk:
        return const Color(0xFF1E6470);
    }
  }

  Color getBorderColor(ColorScheme colors) {
    switch (this) {
      case PostcardAestheticStyle.vintage:
        return colors.primary.withValues(alpha: 0.35);
      case PostcardAestheticStyle.minimal:
        return const Color(0xFFCBD5E1);
      case PostcardAestheticStyle.goldenHour:
        return const Color(0xFFD97706).withValues(alpha: 0.35);
      case PostcardAestheticStyle.nordicFrost:
        return const Color(0xFF1E5E5A).withValues(alpha: 0.3);
      case PostcardAestheticStyle.midnightNoir:
        return const Color(0xFF475569).withValues(alpha: 0.5);
      case PostcardAestheticStyle.cyberGlow:
        return const Color(0xFF38B000).withValues(alpha: 0.45);
      case PostcardAestheticStyle.botanicalPress:
        return const Color(0xFF4F7A45).withValues(alpha: 0.35);
      case PostcardAestheticStyle.desertPostmark:
        return const Color(0xFFC46D32).withValues(alpha: 0.35);
      case PostcardAestheticStyle.monochromeFilm:
        return const Color(0xFF8B8B87).withValues(alpha: 0.45);
      case PostcardAestheticStyle.coastalInk:
        return const Color(0xFF1E6470).withValues(alpha: 0.35);
    }
  }

  bool get isDark {
    return this == PostcardAestheticStyle.midnightNoir ||
        this == PostcardAestheticStyle.cyberGlow;
  }
}

/// Supported aspect ratios for postcard rendering and export
enum PostcardRatio {
  story916,
  feed45,
  square11;

  String get label {
    switch (this) {
      case PostcardRatio.story916:
        return '9:16 Story';
      case PostcardRatio.feed45:
        return '4:5 Feed';
      case PostcardRatio.square11:
        return '1:1 Square';
    }
  }

  IconData get icon {
    switch (this) {
      case PostcardRatio.story916:
        return Icons.smartphone_rounded;
      case PostcardRatio.feed45:
        return Icons.crop_portrait_rounded;
      case PostcardRatio.square11:
        return Icons.crop_square_rounded;
    }
  }

  double get targetWidthConstraint {
    switch (this) {
      case PostcardRatio.story916:
        return 340.0;
      case PostcardRatio.feed45:
        return 320.0;
      case PostcardRatio.square11:
        return 300.0;
    }
  }
}
