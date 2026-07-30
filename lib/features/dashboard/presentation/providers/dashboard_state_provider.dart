import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/presentation/providers/state/dashboard_notifier.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/presentation/providers/state/dashboard_state.dart';

final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
