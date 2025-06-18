import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inteshar/app/config/constants.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.itemList,
    required this.selectedValue,
    required this.onSelected,
  });
  final List<DropdownMenuEntry<String>> itemList;
  final void Function(String?) onSelected;
  final String selectedValue;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.only(left: 8),
          decoration: Constants.intesharBoxDecoration(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 8,
              ),
            ),
          ),
          child: DropdownMenu(
            enableFilter: true,
            requestFocusOnTap: true,
            hintText: 'اختيار',
            trailingIcon: SvgPicture.asset(
              'assets/svgs/angle-small-down.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            ),
            selectedTrailingIcon: SvgPicture.asset(
              'assets/svgs/angle-small-up.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
              fillColor: Theme.of(context).colorScheme.primary,
              border: const UnderlineInputBorder(borderSide: BorderSide.none),
            ),
            searchCallback: (entries, query) {
              final filteredEntries = entries.where((entry) {
                return entry.label.toLowerCase().contains(query.toLowerCase());
              }).toList();

              final count = filteredEntries.length;
              return count > entries.length ? entries.length : count;
            },
            onSelected: onSelected,
            initialSelection: selectedValue,
            // onSelected: (id) {
            //   print(id);
            //   productsApiProvider.fetchProducts(int.tryParse(id!) ?? 0);
            // },
            dropdownMenuEntries: itemList,
          ),
        ),
      ),
    );
  }
}
