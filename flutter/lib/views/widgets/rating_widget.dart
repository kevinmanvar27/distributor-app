import 'package:flutter/material.dart';

/// Rating Widget - Displays star ratings
class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showValue;
  final int? reviewCount;
  final MainAxisAlignment alignment;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 18,
    this.activeColor,
    this.inactiveColor,
    this.showValue = true,
    this.reviewCount,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1;
          IconData icon;
          Color color;

          if (rating >= starValue) {
            icon = Icons.star;
            color = activeColor ?? Colors.amber;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half;
            color = activeColor ?? Colors.amber;
          } else {
            icon = Icons.star_border;
            color = inactiveColor ?? Colors.grey[300]!;
          }

          return Icon(icon, size: size, color: color);
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

/// Interactive Rating Widget - For user input
class InteractiveRatingWidget extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalf;
  final bool enabled;

  const InteractiveRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxRating = 5,
    this.size = 32,
    this.activeColor,
    this.inactiveColor,
    this.allowHalf = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;

        if (rating >= starValue) {
          icon = Icons.star;
          color = activeColor ?? Colors.amber;
        } else if (allowHalf && rating >= starValue - 0.5) {
          icon = Icons.star_half;
          color = activeColor ?? Colors.amber;
        } else {
          icon = Icons.star_border;
          color = inactiveColor ?? Colors.grey[300]!;
        }

        return GestureDetector(
          onTap: enabled ? () => onRatingChanged(starValue.toDouble()) : null,
          onHorizontalDragUpdate: enabled
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final starWidth = size;
                  final newRating = (localPosition.dx / starWidth).clamp(0.0, maxRating.toDouble());
                  
                  if (allowHalf) {
                    onRatingChanged((newRating * 2).round() / 2);
                  } else {
                    onRatingChanged(newRating.ceilToDouble());
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              icon,
              size: size,
              color: enabled ? color : color.withOpacity(0.5),
            ),
          ),
        );
      }),
    );
  }
}

/// Compact Rating Display - Small inline rating
class CompactRatingDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double fontSize;
  final Color? color;

  const CompactRatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.fontSize = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: fontSize + 2,
          color: color ?? Colors.amber,
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        if (reviewCount != null) ...[
          Text(
            ' ($reviewCount)',
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

/// Rating Bar - Horizontal bar showing rating distribution
class RatingBar extends StatelessWidget {
  final int starCount;
  final int totalReviews;
  final int reviewsForStar;
  final Color? barColor;
  final Color? backgroundColor;

  const RatingBar({
    super.key,
    required this.starCount,
    required this.totalReviews,
    required this.reviewsForStar,
    this.barColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalReviews > 0 ? reviewsForStar / totalReviews : 0.0;

    return Row(
      children: [
        Text(
          '$starCount',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star, size: 12, color: Colors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: backgroundColor ?? Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                barColor ?? Theme.of(context).primaryColor,
              ),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            reviewsForStar.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Rating Summary - Complete rating overview with distribution
class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final VoidCallback? onWriteReview;

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Average rating
                Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RatingWidget(
                      rating: averageRating,
                      size: 20,
                      showValue: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Rating distribution
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: RatingBar(
                          starCount: star,
                          totalReviews: totalReviews,
                          reviewsForStar: ratingDistribution[star] ?? 0,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            if (onWriteReview != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onWriteReview,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Write a Review'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Review Card - Individual review display
class ReviewCard extends StatelessWidget {
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String>? images;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final VoidCallback? onHelpful;
  final VoidCallback? onReport;

  const ReviewCard({
    super.key,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.images,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.onHelpful,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage:
                      userAvatar != null ? NetworkImage(userAvatar!) : null,
                  child: userAvatar == null
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          RatingWidget(
                            rating: rating,
                            size: 14,
                            showValue: false,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isVerifiedPurchase)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Comment
            Text(
              comment,
              style: const TextStyle(height: 1.5),
            ),
            // Images
            if (images != null && images!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images![index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
            // Actions
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onHelpful,
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text(
                    helpfulCount > 0 ? 'Helpful ($helpfulCount)' : 'Helpful',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onReport,
                  child: const Text('Report'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}
