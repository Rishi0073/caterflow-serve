import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

const maroon = Color(0xFF800020);
const bgColor = Color(0xFFF5F1EE);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

// ================= MAIN =================
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final screens = [
    OrdersScreen(),
    EarningsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: maroon,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ================= HEADER =================
class HeaderCurve extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurveClipper(),
      child: Stack(
        children: [
          Image.asset(
            "assets/images/header_bg.jpg",
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.menu, color: Colors.white),
                Text("Catering Jobs",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Icon(Icons.notifications_none,
                    color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CURVE
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width / 2,
      size.height - 140,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ================= ORDERS =================
class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String filter = "Nearby";
  Position? userPosition;

  List<Map<String, dynamic>> jobs = [
    {
      "title": "Wedding Service",
      "location": "Bandra",
      "price": 1000,
      "time": "6PM - 12AM",
      "people": 5,
      "lat": 19.0596,
      "lng": 72.8295,
      "image": "assets/images/wedding.jpg"
    },
    {
      "title": "Birthday Party",
      "location": "Kurla",
      "price": 800,
      "time": "7PM - 11PM",
      "people": 3,
      "lat": 19.0726,
      "lng": 72.8826,
      "image": "assets/images/birthday.jpg"
    },
  ];

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever)
      return;

    userPosition =
    await Geolocator.getCurrentPosition();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List sortedJobs = [...jobs];

    if (filter == "Most Money") {
      sortedJobs.sort((a, b) =>
          b["price"].compareTo(a["price"]));
    }

    if (filter == "Nearby" && userPosition != null) {
      sortedJobs.sort((a, b) {
        double d1 = Geolocator.distanceBetween(
          userPosition!.latitude,
          userPosition!.longitude,
          a["lat"],
          a["lng"],
        );
        double d2 = Geolocator.distanceBetween(
          userPosition!.latitude,
          userPosition!.longitude,
          b["lat"],
          b["lng"],
        );
        return d1.compareTo(d2);
      });
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [

          HeaderCurve(),

          // ❌ REMOVED ALL SPACE HERE

          // 🔥 BUTTONS DIRECTLY ATTACHED
          Transform.translate(
            offset: Offset(0, -25), // 👈 PUSH UP
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: [
                bigButton("Nearby"),
                bigButton("Most Money"),
              ],
            ),
          ),

          Expanded(
            child: userPosition == null
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: EdgeInsets.only(top: 0),
              itemCount: sortedJobs.length,
              itemBuilder: (context, i) {
                var job = sortedJobs[i];

                double distance =
                    Geolocator.distanceBetween(
                      userPosition!.latitude,
                      userPosition!.longitude,
                      job["lat"],
                      job["lng"],
                    ) /
                        1000;

                return jobCard(job, distance);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget bigButton(String text) {
    bool selected = filter == text;

    return GestureDetector(
      onTap: () => setState(() => filter = text),
      child: Container(
        padding:
        EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? maroon : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6)
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget jobCard(Map job, double distance) {
    return Container(
      margin: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              job["image"],
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(job["title"],
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(
                      "${job["location"]} • ${distance.toStringAsFixed(1)} km",
                      style: TextStyle(color: Colors.white70)),
                  Text(job["time"],
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}