import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BuildExtension on BuildContext {
  T findBloc<T extends StateStreamableSource<Object?>>() {
    return BlocProvider.of<T>(this);
  }

  double get width {
    return MediaQuery.of(this).size.width;
  }

  double get height {
    return MediaQuery.of(this).size.height;
  }

  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }
}

extension IntExtension on int {
  Widget get heightBox {
    return SizedBox(height: toDouble());
  }

  Widget get widthBox {
    return SizedBox(width: toDouble());
  }

  SliverToBoxAdapter get heightBoxSliver {
    return SliverToBoxAdapter(child: SizedBox(height: toDouble()));
  }

  SliverToBoxAdapter get widthBoxSliver {
    return SliverToBoxAdapter(child: SizedBox(width: toDouble()));
  }
}

extension DoubleExtension on double {
  Widget get heightBox {
    return SizedBox(height: this);
  }

  Widget get widthBox {
    return SizedBox(width: this);
  }

  SliverToBoxAdapter get heightBoxSliver {
    return SliverToBoxAdapter(child: SizedBox(height: this));
  }

  SliverToBoxAdapter get widthBoxSliver {
    return SliverToBoxAdapter(child: SizedBox(width: this));
  }
}

extension StringExtension on String {
  bool get isEmail {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(this);
  }
}

extension StringExtension2 on String? {
  bool get isNullOrEmpty {
    return this == null || this == "";
  }
}

extension WidgetExtension on Widget {
  SliverToBoxAdapter get toSliver {
    return SliverToBoxAdapter(child: this);
  }
}
