import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Search input with a clear button and an adjacent filter button.
/// Calls [onSearchChanged] on every keystroke.
/// Dismisses the keyboard when the user taps outside the field.
class SearchBarSection extends StatefulWidget {
  const SearchBarSection({required this.onSearchChanged, super.key});

  final ValueChanged<String> onSearchChanged;

  @override
  State<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<SearchBarSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onSearchChanged('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector on the outermost widget closes the keyboard when the
    // user taps anywhere outside the text field.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, AppSpacing.md, 20.w, AppSpacing.md),
        child: Row(
          children: [
            Expanded(child: _buildSearchField(context)),
            SizedBox(width: 10.w),
            _buildFilterButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: AppSizes.iconXxl,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchProjectsTeams,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: AppSizes.iconMd,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _clear,
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade400,
                    size: AppSizes.iconSm,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Container(
      width: AppSizes.iconXxl,
      height: AppSizes.iconXxl,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.tune_rounded, color: Colors.white, size: AppSizes.iconMd),
    );
  }
}
