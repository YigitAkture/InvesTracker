/// Shared enum for asset/debt exchange type selection.
///
/// Previously declared independently in both [AddAssetBox] and [AddDebtBox],
/// which would cause a conflict if both were ever imported in the same scope.
/// Centralising it here eliminates the duplication.
enum ExchangeType { currency, gold, crypto }