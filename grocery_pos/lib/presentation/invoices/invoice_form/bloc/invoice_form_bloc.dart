import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_pos/domain_data/contacts/customers/models/customer_model.dart';
import 'package:grocery_pos/domain_data/contacts/customers/repositories/customer_repository.dart';
import 'package:grocery_pos/domain_data/inventories/products/repositories/product_repository.dart';
import 'package:grocery_pos/domain_data/pos/invoices/models/invoice_model.dart';
import 'package:grocery_pos/domain_data/pos/invoices/repositories/invoice_repository.dart';

part 'invoice_form_event.dart';
part 'invoice_form_state.dart';

class InvoiceFormBloc extends Bloc<InvoiceFormEvent, InvoiceFormState> {
  final InvoiceRepository invoiceRepository;
  final ProductRepository productRepository;
  final CustomerRepository customerRepository;

  InvoiceFormBloc(
      {required this.invoiceRepository,
      required this.productRepository,
      required this.customerRepository})
      : super(InvoiceFormInitial()) {
    on<AddInvoiceEvent>(_addInvoiceEvent);
    on<UpdateInvoiceEvent>(_updateInvoiceEvent);
    on<LoadToEditInvoiceEvent>(_loadToEditInvoiceEvent);
    on<BackCategroyFormEvent>(_backCategroyFormEvent);

    // on<InvoiceValueChangedEvent>(_invoiceValueChangedEvent);
  }

  Future<void> _updateInvoiceEvent(
      UpdateInvoiceEvent event, Emitter<InvoiceFormState> emit) async {
    emit(InvoiceFormLoadingState());
    try {
      // Update the product stock first
      await _updateInvenotoryProductByInvoice(
          model: event.model, type: InvoiceFormType.edit);
      // Update the new Invooice
      await invoiceRepository.updateInvoice(event.model);
      emit(const InvoiceFormSuccessState(
          successMessage: "Update invoice succesfully!"));
    } catch (e) {
      emit(InvoiceFormErrorState(message: e.toString()));
    }
  }

  Future<void> _addInvoiceEvent(
      AddInvoiceEvent event, Emitter<InvoiceFormState> emit) async {
    emit(InvoiceFormLoadingState());
    try {
      // Update the new Invoice
      final newId = await invoiceRepository.getNewInvoiceID();
      await invoiceRepository.createInvoice(event.model.copyWith(
          id: newId, createdDate: event.model.createdDate ?? DateTime.now()));

      // Update the product stock
      await _updateInvenotoryProductByInvoice(
          model: event.model, type: InvoiceFormType.createNew);

      emit(const InvoiceFormSuccessState(
          successMessage: "Update invoice succesfully!"));
    } catch (e) {
      emit(InvoiceFormErrorState(message: e.toString()));
    }
  }

  Future<void> _loadToEditInvoiceEvent(
      LoadToEditInvoiceEvent event, Emitter<InvoiceFormState> emit) async {
    emit(InvoiceFormLoadingState());
    try {
      List<CustomerModel>? customers = event.customers ??
          [
            CustomerModel.empty,
            ...?(await customerRepository.getAllCustomerNames())
          ];

      if (event.type == InvoiceFormType.edit) {
        final latestModel = event.isValueChanged!
            ? event.model
            : await invoiceRepository.getInvoiceByID(event.model!.id!);
        emit(
          InvoiceFormLoadedState(
            invoice: latestModel,
            customers: customers,
            formType: event.type,
            isValueChanged: (event.isValueChanged!),
          ),
        );
      } else {
        final latestModel =
            event.isValueChanged! ? event.model : InvoiceModel.empty;
        emit(
          InvoiceFormLoadedState(
            invoice: latestModel,
            formType: InvoiceFormType.createNew,
            customers: customers,
            isValueChanged:
                (event.isValueChanged! && event.model?.invoiceDetails != null),
          ),
        );
      }
    } catch (e) {
      emit(InvoiceFormErrorState(message: e.toString()));
    }
  }

  Future<void> _backCategroyFormEvent(
      BackCategroyFormEvent event, Emitter<InvoiceFormState> emit) async {
    emit(InvoiceFormInitial());
  }

  Future<void> _updateInvenotoryProductByInvoice(
      {required InvoiceModel model, required InvoiceFormType type}) async {
    try {
      // restore quanity of product which  mean quantity will be nagative
      if (type == InvoiceFormType.edit) {
        // return back the invoices product
        final currentInvoices =
            (await invoiceRepository.getInvoiceByID(model.id!))!;

        for (var invoiceDetail in currentInvoices.invoiceDetails!) {
          await productRepository.updateProductQuantity(
              invoiceDetail.product, -(invoiceDetail.quantity));
        }
      }
      // update product by new invoice
      for (var invoiceDetail in model.invoiceDetails!) {
        await productRepository.updateProductQuantity(
            invoiceDetail.product, invoiceDetail.quantity);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

//   Future<void> _invoiceValueChangedEvent(
//       InvoiceValueChangedEvent event, Emitter<InvoiceFormState> emit) async {
//     try {
//       List<CustomerModel>? customers = [
//         CustomerModel.empty,
//         ...?(await customerRepository.getAllCustomerNames())
//       ];
//       emit(InvoiceFormValueChangedState(
//           formType: event.formType,
//           invoice: event.model,
//           customers: customers));
//     } catch (e) {
//       emit(InvoiceFormErrorState(message: e.toString()));
//     }
//   }
}
