import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class PurchaseService {
  bool get isInitialized;

  Future<bool> init();

  Future<bool> isPlatformSupported();

  Future<bool> canMakePurchases();

  Future<bool> logIn(String userId);

  Future<List<PackageItemModel>> getInAppPurchases();

  Future<bool> purchase(String userId, String identifier, String offeringIdentifier);

  Future<bool> restorePurchases(String userId, {String? entitlementIdentifier});

  Future<List<AppUnlockedFeature>> getUnlockedFeatures();

  Future<bool> isFeatureUnlocked(AppUnlockedFeature feature);
}
