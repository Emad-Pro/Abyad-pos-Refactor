import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- 2. Cubit ---
class SideMenuCubit extends Cubit<SideMenuState> {
  SideMenuCubit() : super(SideMenuState());

  void toggleCollapse() {
    emit(state.copyWith(isCollapsed: !state.isCollapsed));
  }

  // ضفنا isSearching هنا كمتغير اختياري
  void changeMenuItem(SideMenuItem item, {bool isSearching = false}) {
    emit(state.copyWith(
      selectedItem: item,
      isSearching: isSearching,
    ));
  }

  // دالة مخصصة للبحث بس لو حبيت تفتحه/تقفله وأنت في نفس الشاشة
  void toggleSearch(bool isSearching) {
    emit(state.copyWith(isSearching: isSearching));
  }
}
