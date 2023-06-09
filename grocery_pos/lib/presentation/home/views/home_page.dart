import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Authentication Services
import '../../../domain_data/authentications/services.dart';

/// Contact Repositoires
import '../../../domain_data/contacts/customers/repositories/repositories.dart';
import '../../../domain_data/contacts/suppliers/repositories/repositories.dart';

/// Inventories Repositories
import '../../../domain_data/inventories/categories/repositories/repositories.dart';
import '../../../domain_data/inventories/products/repositories/repositories.dart';

/// POS services
import '../../../domain_data/pos/invoices/services.dart';

/// Invoices Services
import '../../../domain_data/store/repositories/repositories.dart';

/// Bloc Controllers
import '../../invoices/invoice_blocs.dart';
import '../../store_profile/bloc/store_form_bloc.dart';
import '../../user_profile/bloc/user_form_bloc.dart';

/// Views
import '../../invoices/invoice_form/views.dart';

/// Widgets
import '../widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationRepository>().currentUser;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => StoreProfileRepository(
            userModel: currentUser,
          ),
        ),
        RepositoryProvider(
          create: (_) => CategoryRepository(
            userModel: currentUser,
          ),
        ),
        RepositoryProvider(
          create: (_) => SupplierRepository(
            userModel: currentUser,
          ),
        ),
        RepositoryProvider(
          create: (_) => CustomerRepository(
            userModel: currentUser,
          ),
        ),
        RepositoryProvider(
          create: (_) => SupplierRepository(
            userModel: currentUser,
          ),
        ),
        RepositoryProvider(
          create: (_) => ProductRepository(
            userModel: currentUser,
          ),
        ),
        RepositoryProvider(
          create: (_) => InvoiceRepository(
            userModel: currentUser,
          ),
        ),
        RepositoryProvider(
          create: (_) => UserRepository(
            firebaseUserModel: currentUser,
          ),
        ),
      ],
      child: const HomePageScreen(),
    );
  }
}

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final invoiceRepository = RepositoryProvider.of<InvoiceRepository>(context);
    final productRepository = RepositoryProvider.of<ProductRepository>(context);
    final customerRepository =
        RepositoryProvider.of<CustomerRepository>(context);
    final storeProfileRepository =
        RepositoryProvider.of<StoreProfileRepository>(context);
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => InvoiceListBloc(
            invoiceRepository: invoiceRepository,
          ),
        ),
        BlocProvider(
          create: (_) => InvoiceFormBloc(
            invoiceRepository: invoiceRepository,
            productRepository: productRepository,
            customerRepository: customerRepository,
          ),
        ),
        BlocProvider(
          create: (_) => StoreFormBloc(
            storeProfileRepository: storeProfileRepository,
          ),
        ),
        BlocProvider(
          create: (_) => UserFormBloc(
            userRepository: userRepository,
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("GroceryPOS"),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: _AddInvoiceButton(),
        drawer: const CustomNavigationDrawer(),
        // bottomNavigationBar: _BottomNavigationBar(),
        body: const SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                title: Text("Menu"),
                children: [
                  Wrap(
                    children: [
                      _ScreenMenuButton(
                        iconData: Icons.point_of_sale,
                        title: "POS",
                      ),
                      _ScreenMenuButton(
                        iconData: Icons.production_quantity_limits,
                        title: "Product",
                      ),
                      _ScreenMenuButton(
                        iconData: Icons.person,
                        title: "Customer",
                      ),
                      _ScreenMenuButton(
                        iconData: Icons.store,
                        title: "Store",
                      ),
                      _ScreenMenuButton(
                        iconData: Icons.inventory,
                        title: "Stock",
                      ),
                      _ScreenMenuButton(
                        iconData: Icons.bar_chart,
                        title: "Report",
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              ExpansionTile(
                leading: Icon(Icons.receipt_long),
                title: Text("Recent Invoices"),
                children: [],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenMenuButton extends StatelessWidget {
  final IconData iconData;
  final String title;

  const _ScreenMenuButton({required this.iconData, required this.title});
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: const Size(68, 68), // button width and height
      child: ClipOval(
        child: Material(
          borderOnForeground: true, // button color
          child: InkWell(
            // splash color
            onTap: () {}, // button pressed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData), // icon
                Text(title), // text
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddInvoiceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const Key("homePage_addNewInvoice_IconButton"),
      child: const Icon(Icons.add),
      onPressed: () async {
        BlocProvider.of<InvoiceFormBloc>(context).add(
          LoadToEditInvoiceEvent(
            model: InvoiceModel.empty,
            type: InvoiceFormType.createNew,
          ),
        );
        Navigator.of(context).push(
          InvoiceEntryForm.route(context),
        );
      },
    );
  }
}
