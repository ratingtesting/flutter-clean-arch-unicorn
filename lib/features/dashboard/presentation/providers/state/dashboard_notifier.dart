import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/presentation/providers/state/dashboard_state.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/paginated_response.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/domain/models/product_model.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';
import 'package:flutter_clean_arch_unicorn/shared/constants.dart';

class DashboardNotifier extends Notifier<DashboardState> {
  late final DashboardRepository dashboardRepository;

  @override
  DashboardState build() {
    dashboardRepository = ref.watch(dashboardRepositoryProvider);
    return const DashboardState.initial();
  }

  bool get isLoading => state.isLoading;

  // Allow initial fetch when total is 0, then only if we have more products to fetch
  bool get canFetchMore =>
      !isLoading &&
      state.state != DashboardConcreteState.fetchedAllProducts &&
      (state.total == 0 || state.productList.length < state.total);

  void resetState() => state = const DashboardState.initial();

  Future<void> fetchProducts() async {
    if (isLoading || !canFetchMore) {
      return;
    }

    final skip = state.productList.length;
    state = state.copyWith(
      state: state.productList.isEmpty
          ? DashboardConcreteState.loading
          : DashboardConcreteState.fetchingMore,
    );

    final response = await dashboardRepository.fetchProducts(skip: skip);
    _updateStateFromResponse(response);
  }

  Future<void> searchProducts(String query) async {
    if (isLoading) return;

    // Reset for new search
    state = state.copyWith(
      state: DashboardConcreteState.loading,
      productList: [],
      page: 0,
      total: 0,
    );

    final response = await dashboardRepository.searchProducts(
      skip: 0,
      query: query,
    );
    _updateStateFromResponse(response);
  }

  /// Shared helper to handle repository response.
  /// Eliminates duplication between fetchProducts and searchProducts.
  void _updateStateFromResponse(
    Either<AppException, PaginatedResponse> response,
  ) {
    response.fold(
      (failure) {
        state = state.copyWith(
          state: DashboardConcreteState.failure,
          message: failure.message,
        );
      },
      (data) {
        final productList = data.data.map((e) => Product.fromJson(e)).toList();
        final isInitialLoad = state.productList.isEmpty;
        final totalProducts = isInitialLoad
            ? productList
            : [...state.productList, ...productList];

        state = state.copyWith(
          productList: totalProducts,
          state: totalProducts.length >= data.total
              ? DashboardConcreteState.fetchedAllProducts
              : DashboardConcreteState.loaded,
          hasData: totalProducts.isNotEmpty,
          page: totalProducts.length ~/ PRODUCTS_PER_PAGE,
          total: data.total,
          message: totalProducts.isEmpty ? 'No products found' : '',
        );
      },
    );
  }
}
