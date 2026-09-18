// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/place_eight.jpeg
  AssetGenImage get placeEight =>
      const AssetGenImage('assets/images/place_eight.jpeg');

  /// File path: assets/images/place_eleven.jpeg
  AssetGenImage get placeEleven =>
      const AssetGenImage('assets/images/place_eleven.jpeg');

  /// File path: assets/images/place_five.jpeg
  AssetGenImage get placeFive =>
      const AssetGenImage('assets/images/place_five.jpeg');

  /// File path: assets/images/place_four.jpeg
  AssetGenImage get placeFour =>
      const AssetGenImage('assets/images/place_four.jpeg');

  /// File path: assets/images/place_nine.jpeg
  AssetGenImage get placeNine =>
      const AssetGenImage('assets/images/place_nine.jpeg');

  /// File path: assets/images/place_one.jpeg
  AssetGenImage get placeOne =>
      const AssetGenImage('assets/images/place_one.jpeg');

  /// File path: assets/images/place_seven.jpeg
  AssetGenImage get placeSeven =>
      const AssetGenImage('assets/images/place_seven.jpeg');

  /// File path: assets/images/place_six.jpeg
  AssetGenImage get placeSix =>
      const AssetGenImage('assets/images/place_six.jpeg');

  /// File path: assets/images/place_ten.jpeg
  AssetGenImage get placeTen =>
      const AssetGenImage('assets/images/place_ten.jpeg');

  /// File path: assets/images/place_three.jpeg
  AssetGenImage get placeThree =>
      const AssetGenImage('assets/images/place_three.jpeg');

  /// File path: assets/images/place_twelve.jpeg
  AssetGenImage get placeTwelve =>
      const AssetGenImage('assets/images/place_twelve.jpeg');

  /// File path: assets/images/place_two.jpeg
  AssetGenImage get placeTwo =>
      const AssetGenImage('assets/images/place_two.jpeg');

  /// File path: assets/images/splash_image.jpeg
  AssetGenImage get splashImage =>
      const AssetGenImage('assets/images/splash_image.jpeg');

  /// File path: assets/images/splash_template.jpeg
  AssetGenImage get splashTemplate =>
      const AssetGenImage('assets/images/splash_template.jpeg');

  /// File path: assets/images/waymark_logo.png
  AssetGenImage get waymarkLogo =>
      const AssetGenImage('assets/images/waymark_logo.png');

  /// File path: assets/images/waymark_logo_transparent.png
  AssetGenImage get waymarkLogoTransparent =>
      const AssetGenImage('assets/images/waymark_logo_transparent.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    placeEight,
    placeEleven,
    placeFive,
    placeFour,
    placeNine,
    placeOne,
    placeSeven,
    placeSix,
    placeTen,
    placeThree,
    placeTwelve,
    placeTwo,
    splashImage,
    splashTemplate,
    waymarkLogo,
    waymarkLogoTransparent,
  ];
}

abstract final class Assets {
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
