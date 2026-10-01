import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/policies_remote_data_source.dart';

/// Shows an admin-managed legal document (Terms / Privacy) as plain text.
class PolicyPage extends StatefulWidget {
  final PolicyType type;
  const PolicyPage({super.key, required this.type});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  late Future<Policy> _future = _load();

  Future<Policy> _load() => sl<PoliciesRemoteDataSource>().get(widget.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mid, size: 20),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: Text(widget.type.title,
            style: AppTextStyles.title.copyWith(fontSize: 16)),
      ),
      body: FutureBuilder<Policy>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snap.hasError || (snap.data?.body ?? '').isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Could not load this document.',
                      style: AppTextStyles.subtitle),
                  TextButton(
                    onPressed: () => setState(() {
                      _future = _load();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final policy = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (policy.updatedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Last updated ${DateFormat('d MMM y').format(policy.updatedAt!)}',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ),
                SelectableText(policy.body,
                    style: AppTextStyles.body.copyWith(height: 1.6)),
              ],
            ),
          );
        },
      ),
    );
  }
}
