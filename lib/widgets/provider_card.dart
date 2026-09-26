import 'package:flutter/material.dart';
import '../theme.dart';

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final VoidCallback onTap;

  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = (provider['avg_rating'] ?? 0).toDouble();
    final reviewCount = provider['review_count'] ?? 0;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: kPrimaryColor.withOpacity(0.12),
                child: Text(
                  (provider['name'] ?? '?').toString().isNotEmpty
                      ? provider['name'].toString()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(provider['service'] ?? '', style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.black45),
                        const SizedBox(width: 2),
                        Text(provider['city'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        const SizedBox(width: 10),
                        const Icon(Icons.star, size: 14, color: Color(0xFFF59F00)),
                        const SizedBox(width: 2),
                        Text('$rating ($reviewCount)', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
