import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'features/ledger/ledger.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => LedgerCubit(InMemoryLedgerRepository()),
      child: const App(),
    ),
  );
}
