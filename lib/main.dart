
import 'package:flutter/material.dart';

void main() {
  runApp(const FoodFinderApp());
}

const Color primaryGreen = Color(0xFF174C3C);
const Color cream = Color(0xFFF8F6F0);
const Color darkText = Color(0xFF202820);

class FoodFinderApp extends StatelessWidget {
  const FoodFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodFinder',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class Restaurant {
  final String name;
  final String category;
  final String address;
  final double rating;
  final String description;
  final IconData icon;
  final Color color;

  const Restaurant({
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<Restaurant> restaurants = [
  Restaurant(
    name: 'Restoran Sederhana',
    category: 'Rumah Makan Padang',
    address: 'Padang, Sumatera Barat',
    rating: 4.8,
    description: 'Menyediakan berbagai menu masakan Padang '
        'dengan cita rasa khas Minangkabau.',
    icon: Icons.restaurant,
    color: Color(0xFFE9B98A),
  ),
  Restaurant(
    name: 'Pagi Sore',
    category: 'Rumah Makan Padang',
    address: 'Padang, Sumatera Barat',
    rating: 4.9,
    description: 'Tempat menikmati aneka hidangan khas '
        'Minang dengan pilihan menu beragam.',
    icon: Icons.dinner_dining,
    color: Color(0xFFD9A78B),
  ),
  Restaurant(
    name: 'Kopi Nan Rancak',
    category: 'Cafe',
    address: 'Padang, Sumatera Barat',
    rating: 4.7,
    description: 'Cafe nyaman untuk bersantai dan menikmati '
        'kopi bersama teman.',
    icon: Icons.local_cafe,
    color: Color(0xFFB8C7A8),
  ),
  Restaurant(
    name: 'Seafood Pantai',
    category: 'Seafood',
    address: 'Padang, Sumatera Barat',
    rating: 4.6,
    description: 'Pilihan makanan laut dengan menu '
        'ikan dan seafood.',
    icon: Icons.set_meal,
    color: Color(0xFF9DC7CB),
  ),
  Restaurant(
    name: 'Bakso Juara',
    category: 'Bakso',
    address: 'Padang, Sumatera Barat',
    rating: 4.5,
    description: 'Bakso hangat dengan kuah gurih '
        'dan pilihan pelengkap.',
    icon: Icons.ramen_dining,
    color: Color(0xFFE7B6A3),
  ),
];

const List<String> categories = [
  'Semua',
  'Rumah Makan Padang',
  'Cafe',
  'Seafood',
  'Bakso',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'Semua';
  String searchText = '';
  int selectedPage = 0;

  final Set<String> favorites = {};

  List<Restaurant> get filteredRestaurants {
    return restaurants.where((restaurant) {
      final matchesCategory = selectedCategory == 'Semua' ||
          restaurant.category == selectedCategory;

      final matchesSearch = restaurant.name
              .toLowerCase()
              .contains(searchText.toLowerCase()) ||
          restaurant.category
              .toLowerCase()
              .contains(searchText.toLowerCase());

      final matchesFavorite = selectedPage == 0 ||
          favorites.contains(restaurant.name);

      return matchesCategory &&
          matchesSearch &&
          matchesFavorite;
    }).toList();
  }

  void toggleFavorite(String name) {
    setState(() {
      if (favorites.contains(name)) {
        favorites.remove(name);
      } else {
        favorites.add(name);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: selectedPage == 0
                  ? buildHome()
                  : buildFavorites(),
            ),
            bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FoodFinder',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: const [
                    Icon(
                      Icons.location_on,
                      color: primaryGreen,
                      size: 17,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Padang, Sumatera Barat',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.restaurant_menu,
                color: primaryGreen,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // GREETING
        const Text(
          'Temukan Kuliner',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const Text(
          'Favoritmu di Kota Padang!',
          style: TextStyle(
            fontSize: 23,
            color: primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Jelajahi berbagai tempat makan menarik '
          'dan temukan cita rasa terbaik.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 22),

        // SEARCH
        TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari restoran atau makanan...',
            prefixIcon: const Icon(
              Icons.search,
              color: primaryGreen,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 25),

        // CATEGORY
        const Text(
          'Kategori Kuliner',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected =
                  selectedCategory == category;

              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: primaryGreen,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : primaryGreen,
                  fontSize: 12,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),

        const SizedBox(height: 25),

        // RESTAURANT LIST
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Restoran Pilihan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            Text(
              '${filteredRestaurants.length} tempat',
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        if (filteredRestaurants.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: Text('Restoran tidak ditemukan.'),
            ),
          ),

        ...filteredRestaurants.map(
          (restaurant) => restaurantCard(restaurant),
        ),
      ],
    );
  }

  Widget buildFavorites() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Restoran Favorit',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Daftar tempat makan yang kamu sukai.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        if (favorites.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text('Belum ada restoran favorit.'),
            ),
          ),
        ...filteredRestaurants.map(
          (restaurant) => restaurantCard(restaurant),
        ),
      ],
    );
  }

  Widget restaurantCard(Restaurant restaurant) {
    final isFavorite = favorites.contains(restaurant.name);

    return GestureDetector(
      onTap: () => showRestaurantDetail(restaurant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 135,
              width: double.infinity,
              decoration: BoxDecoration(
                color: restaurant.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      restaurant.icon,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () =>
                            toggleFavorite(restaurant.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.category,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 15,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        size: 17,
                        color: Colors.amber,
                      ),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showRestaurantDetail(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: restaurant.color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  restaurant.icon,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(restaurant.description),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: primaryGreen),
                  const SizedBox(width: 5),
                  Expanded(child: Text(restaurant.address)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text('Rating ${restaurant.rating}'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    toggleFavorite(restaurant.name);
                  },
                  child: const Text('Tambah ke Favorit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget bottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(Icons.home_rounded, 'Beranda', 0),
          navItem(Icons.favorite_rounded, 'Favorit', 1),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final active = selectedPage == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPage = index;
          if (index == 0) {
            selectedCategory = 'Semua';
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? primaryGreen : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? primaryGreen : Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
