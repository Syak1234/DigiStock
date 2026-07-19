import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_inventory/features/inventory/domain/usecases/inventory_use_cases.dart';
import 'product_form_event.dart';
import 'product_form_state.dart';

class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  final InventoryUseCases useCases;

  ProductFormBloc({required this.useCases}) : super(const ProductFormState()) {
    on<InitializeProductForm>(_onInitialize);
    on<SubmitProductForm>(_onSubmit);
  }

  void _onInitialize(InitializeProductForm event, Emitter<ProductFormState> emit) {
    emit(state.copyWith(
      status: ProductFormStatus.initial,
      isEditing: event.product != null,
    ));
  }

  Future<void> _onSubmit(SubmitProductForm event, Emitter<ProductFormState> emit) async {
    emit(state.copyWith(status: ProductFormStatus.loading));
    try {
      if (state.isEditing) {
        await useCases.updateProduct(event.product);
      } else {
        await useCases.addProduct(event.product);
      }
      emit(state.copyWith(status: ProductFormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ProductFormStatus.failure, errorMessage: e.toString()));
    }
  }
}
