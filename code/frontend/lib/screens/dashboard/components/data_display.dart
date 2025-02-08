import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/animated_data_container.dart';

class DataDisplay extends StatelessWidget {
  const DataDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Time range selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center