import 'dart:async';
import 'dart:io';

import 'package:common_toolkit/widgets/loading_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

enum ImageLoadType { assets, net, loading, fail, file }

class LoadImage extends StatefulWidget {
  LoadImage(this.image,
      {Key? key,
      this.width,
      this.height,
      this.fit = BoxFit.contain,
      this.shape = BoxShape.rectangle,
      this.color,
      this.urlList,
      this.urlIndex = 0,
      this.gaplessPlayback = true,
      this.enableMemoryCache = true,
      this.alignment = Alignment.center,
      this.defaultIcon = "img_error",
      this.loadingBgColor = const Color.fromARGB(79, 153, 153, 153),
      this.borderRadius = const BorderRadius.all(Radius.circular(0))})
      : super(key: key);

  final String? image;
  final String defaultIcon;
  double? width;
  double? height;
  final BoxFit fit;
  final BoxShape shape;
  final Color? color;
  final BorderRadius borderRadius;
  final Alignment alignment;
  bool gaplessPlayback;
  bool enableMemoryCache;
  var loadingBgColor;

  //下面2个使用需要一起传
  final List<String>? urlList;
  int urlIndex;

  @override
  State<LoadImage> createState() => _LoadImageState();
}

class _LoadImageState extends State<LoadImage> {
  int? cacheWidth;

  int? cacheHeight;
  ImageLoadType imageLoadType = ImageLoadType.loading;

  @override
  void initState() {
    super.initState();
    initCache();
    initImageType();
  }

  @override
  void didUpdateWidget(covariant LoadImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      initCache();
      initImageType();
    }
  }

  void initCache() {
    /*if (widget.width == double.infinity) {
      cacheWidth = null;
    } else {
      cacheWidth = widget.width?.toInt();
      if (cacheWidth != null) {
        if (cacheWidth! < 0) {
          cacheWidth = 1;
        }
        cacheWidth = (cacheWidth ?? 1) * 3;
        if ((cacheWidth!) <= 0) {
          cacheWidth = null;
        }
      }
    }
    if (widget.height == double.infinity) {
      cacheHeight = null;
    } else {
      cacheHeight = widget.height?.toInt();
      if (cacheHeight != null) {
        cacheHeight = (cacheHeight ?? 1) * 3;
        if ((cacheHeight!) <= 0) {
          cacheHeight = null;
        }
      }
    }*/

    if (widget.width != null) {
      if (widget.width! < 0) {
        widget.width = 0;
      }
    }
    if (widget.height != null) {
      if (widget.height! < 0) {
        widget.height = 0;
      }
    }
  }

  Future<void> initImageType() async {
    if (widget.image == null ||
        widget.image!.isEmpty ||
        widget.image == 'null') {
      imageLoadType = ImageLoadType.loading;
    } else if (widget.image!.contains("http")) {
      widget.image!.replaceAll('http:///', 'http://');
      widget.image!.replaceAll('https:///', 'https://');

      imageLoadType = ImageLoadType.net;
    } else if (widget.image?.contains('assets') ?? false) {
      imageLoadType = ImageLoadType.assets;
    } else {
      imageLoadType = ImageLoadType.file;
    }

    setState(() {});
  }

  Widget _imgWidget() {
    switch (imageLoadType) {
      case ImageLoadType.file:
        return ExtendedImage.file(File(widget.image!),
            width: widget.width?.abs(),
            height: widget.height?.abs(),
            fit: widget.fit,
            shape: widget.shape,
            color: widget.color,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            alignment: widget.alignment,
            borderRadius: widget.borderRadius,
            gaplessPlayback: widget.gaplessPlayback,
            enableMemoryCache: widget.enableMemoryCache);
      case ImageLoadType.assets:
        return ExtendedImage.asset(getImgPath(widget.image!),
            width: widget.width?.abs(),
            height: widget.height?.abs(),
            fit: widget.fit,
            shape: widget.shape,
            color: widget.color,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            alignment: widget.alignment,
            borderRadius: widget.borderRadius,
            gaplessPlayback: widget.gaplessPlayback,
            enableMemoryCache: widget.enableMemoryCache);

      case ImageLoadType.net:
        return ExtendedImage.network(
          '${widget.image}',
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          shape: widget.shape,
          borderRadius: widget.borderRadius,
          gaplessPlayback: widget.gaplessPlayback,
          handleLoadingProgress: true,
          printError: false,
          enableMemoryCache: widget.enableMemoryCache,
          loadStateChanged: (ExtendedImageState state) =>
              _loadStateChanged(state),
        );
      case ImageLoadType.loading:
        return ExtendedImage.asset(
          getImgPath(widget.defaultIcon),
          fit: widget.fit,
          color: widget.color,
          width: widget.width,
          height: widget.height,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          gaplessPlayback: true,
          enableMemoryCache: widget.enableMemoryCache,
        );

      default:
        return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: const Color(0xFFF4F4F6),
            ),
            width: widget.width,
            height: widget.height,
            child: ExtendedImage.asset(
              getImgPath(widget.defaultIcon),
              fit: BoxFit.scaleDown,
              color: Colors.black12,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
              width: widget.width,
              height: widget.height,
              shape: widget.shape,
              borderRadius: widget.borderRadius,
              gaplessPlayback: widget.gaplessPlayback,
              enableMemoryCache: widget.enableMemoryCache,
            ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _imgWidget();
    /*
    if (widget.image == null ||
        widget.image!.isEmpty ||
        widget.image == 'null') {
      return ExtendedImage.asset(
        getImgPath(widget.defaultIcon),
        fit: widget.fit,
        color: widget.color,
        width: widget.width,
        height: widget.height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        gaplessPlayback: true,
      );
    } else if (widget.image!.contains("http")) {
      widget.image!.replaceAll('///', '//');

      return ExtendedImage.network(
        '${widget.image}',
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        shape: widget.shape,
        borderRadius: widget.borderRadius,
        gaplessPlayback: true,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        handleLoadingProgress: true,
        printError: false,
        loadStateChanged: (ExtendedImageState state) =>
            _loadStateChanged(state),
      );
    } else {
      if (widget.width == null && widget.height == null) {
        return ExtendedImage.asset(
          getImgPath(widget.image!),
          fit: widget.fit,
          shape: widget.shape,
          color: widget.color,
          alignment: widget.alignment,
          gaplessPlayback: true,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          borderRadius: widget.borderRadius,
        );
      } else {
        if (widget.width != null) {
          if (widget.width! < 0) {
            widget.width = 0;
          }
        }
        if (widget.height != null) {
          if (widget.height! < 0) {
            widget.height = 0;
          }
        }

        return ExtendedImage.asset(getImgPath(widget.image!),
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            shape: widget.shape,
            color: widget.color,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            alignment: widget.alignment,
            borderRadius: widget.borderRadius,
            gaplessPlayback: true);
      }
    }*/
  }

  Widget _loadStateChanged(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.completed) {
      return state.completedWidget;
    } else {
      if (state.extendedImageLoadState == LoadState.loading) {
        return const LoadingWidget();
      } else {
        if (widget.urlList != null) {
          return errorStateWidget();
        } else {
          return Container(
              padding: const EdgeInsets.all(30),
              color: const Color(0xFFF4F4F6),
              child: ExtendedImage.asset(
                getImgPath(widget.defaultIcon),
                fit: BoxFit.scaleDown,
                color: Colors.black12,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                gaplessPlayback: widget.gaplessPlayback,
                enableMemoryCache: widget.enableMemoryCache,
              ));
        }
      }
    }
  }

  String getImgPath(String name) {
    String src = name.replaceAll(' ', '');
    if (src.contains('.')) {
      if (src.contains('assets')) {
        return src;
      }
      return 'assets/global/$src';
    }
    return 'assets/global/$src.png';
  }

  Widget errorStateWidget() {
    if (widget.urlList == null) {
      return Container(
          padding: const EdgeInsets.all(30),
          color: const Color(0xFFF4F4F6),
          child: ExtendedImage.asset(
            getImgPath(widget.defaultIcon),
            fit: BoxFit.scaleDown,
            color: Colors.black12,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            gaplessPlayback: widget.gaplessPlayback,
            enableMemoryCache: widget.enableMemoryCache,
          ));
    }
    int newIndex = widget.urlIndex + 1;
    if (newIndex > widget.urlList!.length - 1) {
      return Container(
          padding: const EdgeInsets.all(30),
          color: const Color(0xFFF4F4F6),
          child: ExtendedImage.asset(
            getImgPath(widget.defaultIcon),
            fit: BoxFit.scaleDown,
            color: Colors.black12,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            gaplessPlayback: widget.gaplessPlayback,
          ));
    } else {
      return LoadImage(
        widget.urlList![newIndex],
        fit: BoxFit.fitWidth,
        width: 234,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        urlList: widget.urlList,
        urlIndex: newIndex,
      );
    }
  }
}
