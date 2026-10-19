import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/formatting/price_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/payment_status.dart';
import 'meal_image.dart';

class OrderTile extends StatelessWidget {
  const OrderTile(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemCount = order.items.fold<int>(
      0,
      (count, item) => count + item.quantity,
    );
    final firstMeal = order.items.firstOrNull?.meal;
    final title = firstMeal == null
        ? AppStrings.order
        : order.items.length == 1
        ? firstMeal.name
        : '${firstMeal.name} + ${order.items.length - 1}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: firstMeal == null
                  ? const Icon(Icons.restaurant)
                  : MealImage(firstMeal),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.sectionFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount ${itemCount == 1 ? AppStrings.item : AppStrings.items} · ${_dateLabel(order.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                PriceFormatter.format(order.totalCents),
                style: const TextStyle(
                  fontFamily: AppTheme.sectionFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _statusLabel(order.paymentStatus),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(PaymentStatus status) => switch (status) {
    PaymentStatus.paid => AppStrings.paidStatus,
    PaymentStatus.dueOnDelivery => AppStrings.cashOnDeliveryStatus,
    PaymentStatus.pending => AppStrings.pendingStatus,
  };

  String _dateLabel(DateTime date) {
    final localDate = date.toLocal();
    final today = DateTime.now();
    final days = DateTime(today.year, today.month, today.day)
        .difference(DateTime(localDate.year, localDate.month, localDate.day))
        .inDays;
    if (days == 0) return AppStrings.today;
    if (days == 1) return AppStrings.yesterday;
    if (days > 1 && days < 7) return '$days ${AppStrings.daysAgo}';
    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }
}
