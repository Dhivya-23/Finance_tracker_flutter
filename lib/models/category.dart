
class Category {
  final String name;
  final bool isExpense;

  Category({required this.name, this.isExpense = true});
}

List<Category> predefinedCategories = [
  Category(name: "Salary", isExpense: false),
  Category(name: "Freelancing", isExpense: false),
  Category(name: "Food"),
  Category(name: "Transport"),
  Category(name: "Entertainment"),
];
