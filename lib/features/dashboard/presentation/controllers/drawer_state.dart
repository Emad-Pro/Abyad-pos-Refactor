enum SideMenuItem { home, orders, invoices, settings }

// --- 1. State ---
class SideMenuState {
  final bool isCollapsed;
  final SideMenuItem selectedItem;
  final bool isSearching; // ضفنا دي هنا

  SideMenuState({
    this.isCollapsed = false,
    this.selectedItem = SideMenuItem.home,
    this.isSearching = false, // القيمة الافتراضية
  });

  SideMenuState copyWith({
    bool? isCollapsed,
    SideMenuItem? selectedItem,
    bool? isSearching,
  }) {
    return SideMenuState(
      isCollapsed: isCollapsed ?? this.isCollapsed,
      selectedItem: selectedItem ?? this.selectedItem,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
