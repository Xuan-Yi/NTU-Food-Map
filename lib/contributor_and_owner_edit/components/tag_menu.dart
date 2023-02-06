import 'package:flutter/material.dart';

// All tags
const List<Map<String, String>> tags = [
  // Service options
  {'category': 'Service options', 'feature': 'Dine-in'},
  {'category': 'Service options', 'feature': 'Takeaway'},
  {'category': 'Service options', 'feature': 'Delivery'},
  {'category': 'Service options', 'feature': 'foodpanda'},
  {'category': 'Service options', 'feature': 'Uber Eats'},
  {'category': 'Service options', 'feature': 'LaLaMove'},
  // Highlights
  {'category': 'Highlights', 'feature': 'Fast service'},
  {'category': 'Highlights', 'feature': 'Fireplace'},
  {'category': 'Highlights', 'feature': 'Great for studing'},
  {'category': 'Highlights', 'feature': 'Great for dine together'},
  {'category': 'Highlights', 'feature': 'Nice service'},
  {'category': 'Highlights', 'feature': 'Muslim Friendly'},
  {'category': 'Highlights', 'feature': 'Free drinks'},
  {'category': 'Highlights', 'feature': 'Free soups'},
  {'category': 'Highlights', 'feature': 'Bar on site'},
  {'category': 'Highlights', 'feature': 'Toilets'},
  {'category': 'Highlights', 'feature': 'Special offers(優惠)'},
  // Accessibility
  {'category': 'Accessibility', 'feature': 'Wheelchair-accessible car park'},
  {'category': 'Accessibility', 'feature': 'Wheelchair-accessible entrance'},
  {'category': 'Accessibility', 'feature': 'Wheelchair-accessible lift'},
  {'category': 'Accessibility', 'feature': 'Wheelchair-accessible seating'},
  {'category': 'Accessibility', 'feature': 'Wheelchair-accessible toilet'},
  // Offerings
  {'category': 'Offerings', 'feature': 'Vegetarian options'},
  {'category': 'Offerings', 'feature': 'Ramen'},
  {'category': 'Offerings', 'feature': 'Japanese meals'},
  {'category': 'Offerings', 'feature': 'Ti-styled Japanese food'},
  {'category': 'Offerings', 'feature': 'Italian meals'},
  {'category': 'Offerings', 'feature': 'Ti-styled Italian food'},
  {'category': 'Offerings', 'feature': 'Rice dishes'},
  {'category': 'Offerings', 'feature': 'Hot pot'},
  {'category': 'Offerings', 'feature': 'Noodle dishes'},
  {'category': 'Offerings', 'feature': 'Cafeteria dishes(自助餐)'},
  {'category': 'Offerings', 'feature': 'Chinese breakfast foods(中式早餐)'},
  {'category': 'Offerings', 'feature': 'Fast foods'},
  {'category': 'Offerings', 'feature': 'Beer'},
  {'category': 'Offerings', 'feature': 'Alchohol'},
  {'category': 'Offerings', 'feature': 'Wine'},
  {'category': 'Offerings', 'feature': 'Cocktail'},
  {'category': 'Offerings', 'feature': 'Coffee'},
  {'category': 'Offerings', 'feature': 'Drinks'},
  {'category': 'Offerings', 'feature': 'Water'},
  // Dining options
  {'category': 'Dining options', 'feature': 'Breakfast'},
  {'category': 'Dining options', 'feature': 'Brunch'},
  {'category': 'Dining options', 'feature': 'Lunch'},
  {'category': 'Dining options', 'feature': 'Dinner'},
  {'category': 'Dining options', 'feature': 'Afternoon tea'},
  {'category': 'Dining options', 'feature': 'Late-night supper(宵夜)'},
  {'category': 'Dining options', 'feature': 'Dessert'},
  // Crowd
  {'category': 'Crowd', 'feature': 'University students'},
  {'category': 'Crowd', 'feature': 'University employees & teachers'},
  {'category': 'Crowd', 'feature': 'Groups'},
  {'category': 'Crowd', 'feature': 'Elders'},
  {'category': 'Crowd', 'feature': 'Family'},
  // Payments
  {'category': 'Payments', 'feature': 'Cash only'},
  {'category': 'Payments', 'feature': 'Credit card'},
  {'category': 'Payments', 'feature': 'EasyCard(悠遊卡)'},
  {'category': 'Payments', 'feature': 'iPASS Card(一卡通)'},
  {'category': 'Payments', 'feature': 'LINE Pay'},
  {'category': 'Payments', 'feature': 'Apple Pay'},
  {'category': 'Payments', 'feature': 'SAMSUNG Pay'},
  {'category': 'Payments', 'feature': 'Google Pay'},
  {'category': 'Payments', 'feature': '街口支付'},
  {'category': 'Payments', 'feature': '悠游付'},
];

// Get tag chosen
List<bool> getTagChosen({required List myTag}) {
  List<bool> tagChosen = List.filled(tags.length, false);

  if (myTag.isNotEmpty) {
    for (int i = 0; i < tags.length; i++) {
      if (myTag.map((e) => e['feature']).contains(tags[i]['feature'])) {
        tagChosen[i] = true;
      }
    }
  }
  return tagChosen;
}

// Tag menu
class TagMenu extends StatelessWidget {
  const TagMenu({
    Key? key,
    required this.tagChosen,
    required this.toggleTag,
    required this.showTags,
    required this.setVisible,
  }) : super(key: key);

  final List<bool> tagChosen;
  final bool showTags;
  final ValueChanged<int> toggleTag;
  final ValueChanged<bool> setVisible;

  // Tag widget of specific category
  Widget _tagWidgets(
    String category,
  ) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            category,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: tags
                .where((t) => t['category'] == category)
                .map(
                  (e) => ElevatedButton.icon(
                    onPressed: () => toggleTag(tags.indexOf(e)),
                    style: ElevatedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2.4),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: tagChosen[tags.indexOf(e)]
                                ? Colors.green
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: tagChosen[tags.indexOf(e)]
                        ? const Icon(Icons.remove_circle,
                            color: Colors.green, size: 12)
                        : const Icon(Icons.add, color: Colors.grey, size: 12),
                    label: Text(
                      "${e['feature']}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: tagChosen[tags.indexOf(e)]
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        // Tag title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tags',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setVisible(!showTags),
              child: Text(
                showTags ? 'Close' : 'Edit',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        // Tags
        Container(
          child: showTags
              ? Column(
                  children: [
                    _tagWidgets('Service options'),
                    _tagWidgets('Highlights'),
                    _tagWidgets('Accessibility'),
                    _tagWidgets('Offerings'),
                    _tagWidgets('Dining options'),
                    _tagWidgets('Crowd'),
                    _tagWidgets('Payments'),
                    // Close button
                    ElevatedButton(
                      onPressed: () => setVisible(!showTags),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(36),
                        shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(width: 2, color: Colors.grey),
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Hide tags',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              : null,
        ),
      ],
    );
  }
}
