import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot_btl/screens/components/smart_device_box.dart';
import 'package:iot_btl/screens/rfid_page.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // padding constants
  final double horizontalPadding = 20;
  final double verticalPadding = 10;
  double humiditySensorValue = 0.0;
  double temperatureSensorValue = 0.0;
  bool fish = false;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? newCards = '';
  final TextEditingController _nameController = TextEditingController();
  bool isOpenedDoor = false;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _fetchInitialDeviceStates();
    _fetchHumidityData();
    _checkNewCards();
    _fetchTemperatureData();
  }

  void _checkNewCards() async {
    final ref = _database.child('newCards');
    ref.onValue.listen((event) {
      setState(() {
        newCards = event.snapshot.value as String;
      });
    });
  }

  void _saveCard(String name) async {
    if (newCards != null && newCards!.isNotEmpty) {
      final ref = _database;
      await ref.child('allowedCards').child(newCards!).set(name);

      // Set newCards to "" to clear the data
      await ref.child('newCards').set("");

      // Clear the text field
      _nameController.clear();
    }
  }

  void _fetchHumidityData() {
    final DatabaseReference database = FirebaseDatabase.instance.ref();

    // Lắng nghe trực tiếp giá trị 'humidity'
    database.child('humidity').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          humiditySensorValue =
              double.parse(data.toString()); // Chuyển sang double
        });
      }
    });
  }

  void _fetchTemperatureData() {
    _database.child('temperature').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          temperatureSensorValue = double.parse(data.toString());
        });
      }
    });
  }

  // list of smart devices
  List mySmartDevices = [
    // [ smartDeviceName, iconPath , powerStatus ]

    ["Đèn phòng khách", "assets/living-light.png", true, "v0"],
    ["Đèn phòng ngủ", "assets/bed-light.png", false, "v1"],
    ["Đèn hiên", "assets/garden-light.png", false, "v2"],
    ["Đèn tầng 2", "assets/lamp.png", false, "v3"],
    ["Đèn bể cá", "assets/fish_light.png", false, "v4"],
    ["Máy bơm bể cá", "assets/fish_light.png", false, "v5"],
  ];

  void _fetchInitialDeviceStates() {
    for (var i = 0; i < mySmartDevices.length; i++) {
      String deviceId = mySmartDevices[i][3];

      _database.child(deviceId).onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            mySmartDevices[i][2] = data == true;
          });
        }
      });
    }
    _database.child('door').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
           isOpenedDoor = data == true;
          });
        }
      });
  }

  // power button switched
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });
    _database.child(mySmartDevices[index][3]).set(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: newCards != null && newCards!.isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  // Show dialog or other logic for name input
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Nhập tên người dùng"),
                        content: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên',
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              String userName = _nameController.text;

                              if (userName.isNotEmpty) {
                                Navigator.of(context).pop();
                                _saveCard(userName);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Vui lòng nhập tên người dùng')),
                                );
                              }
                            },
                            child: const Text('Lưu'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                      // color: ?
                      ),
                  child: Image.asset("assets/rfid.png"),
                ),
              )
            : null,
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // app bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // menu icon
                    Image.asset(
                      'assets/menu.png',
                      height: 45,
                      color: Colors.grey[800],
                    ),

                    // account icon
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const AllowedCardsPage();
                        }));
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                            // color: ?
                            ),
                        child: Image.asset("assets/rfid.png"),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // welcome home
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chào mừng về nhà",
                      style:
                          TextStyle(fontSize: 30, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),

              SizedBox(
                height: 200,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 200,
                        margin: const EdgeInsets.only(right: 20),
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NHIỆT ĐỘ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: fish ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 110,
                              child: SleekCircularSlider(
                                min: 0,
                                max: 110,
                                initialValue: temperatureSensorValue,
                                appearance: CircularSliderAppearance(
                                  spinnerMode: false,
                                  customWidths: CustomSliderWidths(
                                    shadowWidth: 10,
                                  ),
                                  customColors: CustomSliderColors(
                                    trackColor: Colors.black,
                                    progressBarColor: const Color.fromARGB(
                                        255, 239, 177, 177),
                                  ),
                                ),
                                onChange: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: Container(
                    //     height: 200,
                    //     alignment: Alignment.center,
                    //     margin: const EdgeInsets.only(left: 20),
                    //     child: SmartDeviceBox(
                    //       smartDeviceName: "Máy bơm cho bể cá",
                    //       iconPath: "assets/fish.png",
                    //       powerOn: fish,
                    //       onChanged: (value) {},
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 200,
                        margin: const EdgeInsets.only(right: 20),
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ĐỘ ẨM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: fish ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 110,
                              child: SleekCircularSlider(
                                min: 0,
                                max: 110,
                                initialValue: humiditySensorValue,
                                appearance: CircularSliderAppearance(
                                  spinnerMode: false,
                                  customWidths: CustomSliderWidths(
                                    shadowWidth: 10,
                                  ),
                                  customColors: CustomSliderColors(
                                    trackColor: Colors.black,
                                    progressBarColor: const Color.fromARGB(
                                        255, 239, 177, 177),
                                  ),
                                ),
                                onChange: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/door.png",
                        height: 200,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        height: 200,
                        child: SmartDeviceBox(
                          isDoor: true,
                          smartDeviceName: "Cửa",
                          iconPath: isOpenedDoor
                              ? "assets/opened_door.png"
                              : "assets/closed_door.png",
                          powerOn: isOpenedDoor,
                          onChanged: (value) async {
                            final bool didAuthenticate = await auth.authenticate(
                                localizedReason:
                                    'Please authenticate to show account balance',
                                options: const AuthenticationOptions());
                            if (didAuthenticate) {
                              setState(() {
                                isOpenedDoor = value;
                              });
                              _database
                                  .child('door')
                                  .set(value);
                            }
                            // powerSwitchChanged(value, index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // smart devices grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  "Smart Devices",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // grid
              GridView.builder(
                itemCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.3,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: SmartDeviceBox(
                      smartDeviceName: mySmartDevices[index][0],
                      iconPath: mySmartDevices[index][1],
                      powerOn: mySmartDevices[index][2],
                      onChanged: (value) => powerSwitchChanged(value, index),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 28,
              )
            ],
          ),
        ),
      ),
    );
  }
}
