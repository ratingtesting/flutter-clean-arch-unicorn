// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/product/product_model.dart';

enum DashboardConcreteState {
  initial,
  loading,
  loaded,
  failure,
  fetchingMore,
  fetchedAllProducts
}

class DashboardState extends Equatable {
  final List<Product> productList;
  final int total;
  final int page;
  final bool hasData;
  final DashboardConcreteState state;
  final String message;

  const DashboardState({
    this.productList = const [],
    this.hasData = false,
    this.state = DashboardConcreteState.initial,
    this.message = '',
    this.page = 0,
    this.total = 0,
  });

  const DashboardState.initial({
    this.productList = const [],
    this.total = 0,
    this.page = 0,
    this.hasData = false,
    this.state = DashboardConcreteState.initial,
    this.message = '',
  });

  bool get isLoading =>
      state == DashboardConcreteState.loading ||
      state == DashboardConcreteState.fetchingMore;

  DashboardState copyWith({
    List<Product>? productList,
    int? total,
    int? page,
    bool? hasData,
    DashboardConcreteState? state,
    String? message,
  }) {
    return DashboardState(
      productList: productList ?? this.productList,
      total: total ?? this.total,
      page: page ?? this.page,
      hasData: hasData ?? this.hasData,
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return 'DashboardState(isLoading:${isLoading}, productLength: ${productList.length},total:$total page: $page, hasData: $hasData, state: $state, message: $message)';
  }

  @override
  List<Object?> get props => [productList, page, hasData, state, message];
}
