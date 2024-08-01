import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
class InAppPurchaseUtils {
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  //单例
  static InAppPurchaseUtils _instance = InAppPurchaseUtils._internal();

  factory InAppPurchaseUtils() => _instance;

  InAppPurchaseUtils._internal() {
    init();
  }

  void init() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //_handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          /*  bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }*/
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  ///购买
  Future<bool> buyConsumable({
    required String kIds,
  }) async {
    if (!Platform.isAndroid) return false;
    // 判断商店是否可用
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      return false;
    }

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({kIds});
    if (response.notFoundIDs.isNotEmpty) {
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );

    await InAppPurchase.instance.buyConsumable(
      purchaseParam: purchaseParam,
    );
    return true;
  }
}
