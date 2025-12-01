import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/models/gold_data.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/market/gold/widgets/gold_box.dart';

class GoldRates extends StatefulWidget {
  final List<GoldData> golds;
  
  const GoldRates({
    super.key,
    required this.golds,
  });

  @override
  State<GoldRates> createState() => GoldRatesState();
}

class GoldRatesState extends State<GoldRates> {
  bool _showAll = false;

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
    });
  }

  List<GoldData> _getDisplayedGolds() {
    if (_showAll) {
      return widget.golds;
    } else {
      // Show only first 5 gold types (default ones)
      const defaultCodes = ['HAS', 'GRA', 'CEYREKALTIN', 'YARIMALTIN', 'TAMALTIN'];
      return widget.golds
          .where((gold) => defaultCodes.contains(gold.code))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (widget.golds.isEmpty) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text(
          l10n.noGoldDataAvailable,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }

    final displayedGolds = _getDisplayedGolds();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Gold list
        Column(
          children: displayedGolds
              .map((gold) => GoldBox(gold: gold))
              .toList(),
        ),

        // Show More/Less button
        if (widget.golds.length > 6)
          Padding(
            padding: EdgeInsets.only(top: 4.h, right: 4.w),
            child: TextButton(
              onPressed: _toggleShowAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showAll ? l10n.showLess : l10n.showMore,
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
}