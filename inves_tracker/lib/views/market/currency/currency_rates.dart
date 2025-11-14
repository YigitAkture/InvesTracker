import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/models/currency_data.dart';
import 'package:inves_tracker/core/services/currency_service.dart';
import 'package:inves_tracker/views/market/currency/widgets/currency_box.dart';

class CurrencyRates extends StatefulWidget {
  const CurrencyRates({super.key, this.onUpdate});

  final void Function(String updateTime)? onUpdate;

  @override
  State<CurrencyRates> createState() => _CurrencyRatesState();
}

class _CurrencyRatesState extends State<CurrencyRates> {
  final CurrencyService _currencyService = CurrencyService();
  List<CurrencyData> _currencies = [];
  String _updateTime = '';
  bool _isLoading = true;
  bool _showAll = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _currencyService.fetchCurrencies(
        showAll: _showAll,
      );
      setState(() {
        _currencies = response.currencies;
        _updateTime = response.updateTime;
        _isLoading = false;
      });

      if (widget.onUpdate != null) {
        widget.onUpdate!(_updateTime);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load currency rates';
        _isLoading = false;
      });
    }
  }

  // Public method to allow external refresh
  Future<void> loadCurrencies() async {
    await _loadCurrencies();
  }

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
    });
    _loadCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Currency list
        if (_isLoading)
          _buildLoadingState()
        else if (_errorMessage != null)
          _buildErrorState()
        else
          _buildCurrencyList(),

        // Show More/Less button
        if (!_isLoading && _errorMessage == null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, right: 4.w),
            child: TextButton(
              onPressed: _toggleShowAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showAll ? 'Show Less' : 'See More...',
                    style: TextStyle(
                      fontSize: 13.sp,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    _showAll
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary(context)),
          SizedBox(height: 12.h),
          Text(
            'Loading currency rates...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppColors.danger),
          SizedBox(height: 12.h),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadCurrencies,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyList() {
    return Column(
      children: _currencies
          .map((currency) => CurrencyBox(currency: currency))
          .toList(),
    );
  }
}
