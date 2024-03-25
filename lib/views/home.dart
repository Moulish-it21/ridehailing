import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_webservice/places.dart';
import 'package:taxi/controller/authController.dart';
import 'package:taxi/views/Drivers/DecisionScreen.dart';
import 'package:taxi/views/login_screen.dart';
import 'package:taxi/views/profile.dart';
import 'package:taxi/widgets/textwidget.dart';

import '../utils/app_colors.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _mapStyle;

  AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    authController.getUserInfo();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(11.4970126, 77.2745275),
    zoom: 14.4746,
  );

  GoogleMapController? myMapController ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
      ),
      drawer: buildDrawer(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller){
                myMapController = controller;
                myMapController!.setMapStyle(_mapStyle);
              }, initialCameraPosition:_kGooglePlex,
            ),
          ),


          buildProfileTile(),

          buildTextField(),

          //showSourceField ? buildTextFieldForSource() : Container(),

          buildTextFieldForSource(),

          buildCurrentLocationIcon(),

          buildNotificationIcon(),

          buildBottomSheet(),
        ],
      ),
    );
  }

  Widget buildProfileTile(){
    return Positioned(
      top: 10,
      left: 20,
      right: 20,
      child:  Obx(()=>authController.MyUser.value.name == null ? Center(
        child: CircularProgressIndicator(
          color: Colors.green,
          backgroundColor: Colors.blueGrey,
        ),
      )
          : Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: authController.MyUser.value.image == null ? DecorationImage(
                    image: AssetImage('assets/man.png'),
                    fit: BoxFit.fill,
                  ) : DecorationImage(
                    image: NetworkImage(authController.MyUser.value.image!),
                    fit: BoxFit.fill,
                  )
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      children:[
                        TextSpan(
                          text: 'Good Morning, ',
                          style: TextStyle(color: Colors.black,fontSize: 14),
                        ),
                        TextSpan(
                          text: authController.MyUser.value.name,
                          style: TextStyle(color: Colors.green,fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      ]
                  ),
                ),
                Text("Where are you going?",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Colors.black),)

              ],
            )
          ],
        ),
      ),),
    );
  }

  Future<String?> showGoogleAutoComplete()async {
    const kGoogleApiKey = "AIzaSyACCgdK4V6HVEcjOyR4sxRYm1QCpyFJI50";
    Prediction? p = await PlacesAutocomplete.show(
        offset: 0,
        radius: 1000,
        strictbounds: false,
        region: 'us',
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay, // Mode.fullscreen
        language: "en",
        hint: "Search City",
        types: ["(cities)"],
        components: [new Component(Component.country, "us")]
    );

  }


  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();


  bool showSourceField = false;

  Widget buildTextField(){
    return Positioned(
      top: 170,
      left: 20,
      right: 20,
      child: Container(
        width: Get.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color:Colors.black.withOpacity(0.05),
                  spreadRadius:4,
                  blurRadius:10
              ),
            ],
            borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          controller: destinationController,
          readOnly: true,
          onTap: ()async{
            String? selectedPlace = await showGoogleAutoComplete();
            destinationController.text = selectedPlace!;

            setState(() {
              showSourceField = true;
            });
          },
          style: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.bold,),
          decoration: InputDecoration(
            hintText: 'Search for a destination',
            hintStyle: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.bold,),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                Icons.search,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldForSource(){
    return Positioned(
      top: 230,
      left: 20,
      right: 20,
      child: Container(
        width: Get.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color:Colors.black.withOpacity(0.05),
                  spreadRadius:4,
                  blurRadius:10
              ),
            ],
            borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          controller: sourceController,
          readOnly: true,
          onTap: ()async{
            Get.bottomSheet(
                Container(
                  width: Get.width,
                  height: Get.height*0.5,
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      color: Colors.white
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),

                      Text(
                        "Select Your Location",
                        style: TextStyle(
                          color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Text(
                        "Home Address",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: Get.width,
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  spreadRadius: 4,
                                  blurRadius: 10
                              ),
                            ]
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Sathyamangalam, Erode",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Text(
                        "Business Address",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: Get.width,
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  spreadRadius: 4,
                                  blurRadius: 10
                              ),
                            ]
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Sathyamangalam, Erode",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: ()async{
                          Get.back();
                          String? place = await showGoogleAutoComplete();
                          sourceController.text = place!;
                        },
                        child: Container(
                          width: Get.width,
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    spreadRadius: 4,
                                    blurRadius: 10
                                ),
                              ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Search for Address",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,

                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                )
            );
          },
          style: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.bold,),
          decoration: InputDecoration(
            hintText: 'From: ',
            hintStyle: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.bold,),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                Icons.search,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),

    );
  }



  Widget buildCurrentLocationIcon(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30,right: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green,
          child: Icon(Icons.my_location,color: Colors.white,),
        ),
      ),
    );
  }

  Widget buildNotificationIcon(){
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30,left: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(Icons.notifications,color: Color(0xffC3CDD6),),

        ),
      ),
    );
  }

  Widget buildBottomSheet(){
    return GestureDetector(
      onTap: (){
        buildRideConfirmationSheet();
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: Get.width*0.8,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 4,
                blurRadius: 10,
              )
            ],
            borderRadius:BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Container(
              width: Get.width*0.6,
              height: 4,
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );

  }
  buildDrawerItem(
      {required String title,
        required Function onPressed,
        Color color = Colors.black,
        double fontSize = 20,
        FontWeight fontWeight = FontWeight.w700,
        double height = 45,
        bool isVisible = false}) {
    return SizedBox(
      height: height,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        // minVerticalPadding: 0,
        dense: true,
        onTap: () => onPressed(),
        title: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: fontSize, fontWeight: fontWeight, color: color),
            ),
            const SizedBox(
              width: 5,
            ),
            isVisible
                ? CircleAvatar(
              backgroundColor: AppColors.greenColor,
              radius: 15,
              child: Text(
                '1',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }

  buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => const MyProfile());
            },
            child: SizedBox(
              height: 150,
              child: DrawerHeader(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: authController.MyUser.value.image == null
                              ? DecorationImage(
                              image: AssetImage('assets/man.png'),
                              fit: BoxFit.fill
                          ) : DecorationImage(
                              image: NetworkImage(authController.MyUser.value.image!),
                              fit: BoxFit.fill
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Good Morning, ',
                                style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.28),
                                    fontSize: 14)),
                            Text(
                              authController.MyUser.value.name == null
                                  ? "User"
                                  : authController.MyUser.value.name!,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,

                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                buildDrawerItem(title: 'Payment History', onPressed:(){}),
                buildDrawerItem(
                    title: 'Ride History', onPressed: () {}, isVisible: true),
                buildDrawerItem(title: 'Invite Friends', onPressed: () {}),
                buildDrawerItem(title: 'Promo Codes', onPressed: () {}),
                buildDrawerItem(title: 'Settings', onPressed: () {}),
                buildDrawerItem(title: 'Support', onPressed: () {}),
                buildDrawerItem(title: 'Log Out', onPressed: () {

                  FirebaseAuth.instance.signOut();

                  Get.to(()=> DecisionScreen());


                }),
              ],
            ),
          ),
          Spacer(),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                buildDrawerItem(
                    title: 'Do more',
                    onPressed: () {},
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.15),
                    height: 20),
                const SizedBox(
                  height: 20,
                ),
                buildDrawerItem(
                    title: 'Get food delivery',
                    onPressed: () {},
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.15),
                    height: 20),
                buildDrawerItem(
                    title: 'Make money driving',
                    onPressed: () {},
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.15),
                    height: 20),
                buildDrawerItem(
                  title: 'Rate us on store',
                  onPressed: () {},
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.15),
                  height: 20,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );

  }

  buildRideConfirmationSheet(){
    Get.bottomSheet(
      Container(
        width: Get.width,
        height: Get.height * 0.4,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12), topLeft: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                width: Get.width * 0.2,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            textWidget(
              text: 'Select an Option',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(
              height: 20,
            ),
            buildDriversList(),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
              ),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: buildPaymentCardWidget()),
                    MaterialButton(
                      onPressed: () {},
                      child: textWidget(
                        text: 'Confirm',
                        color: Colors.white,
                      ),
                      color: AppColors.greenColor,
                      shape: StadiumBorder(),
                    ),
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
  int selectedRide = 0;

  buildDriversList() {
    return Container(
      height: 90,
      width: Get.width,
      child: StatefulBuilder(builder: (context, set) {
        return ListView.builder(
          itemBuilder: (ctx, i) {
            return InkWell(
              onTap: () {
                set(() {
                  selectedRide = i;
                });
              },
              child: buildDriverCard(selectedRide == i),
            );
          },
          itemCount: 3,
          scrollDirection: Axis.horizontal,
        );
      }),
    );
  }
  buildDriverCard(bool selected) {
    return Container(
        margin: EdgeInsets.only(right: 8, left: 8, top: 4, bottom: 4),
    height: 85,
    width: 165,
    decoration: BoxDecoration(
    boxShadow: [
    BoxShadow(
    color: selected
    ? Colors.blue.withOpacity(0.2)
        : Colors.grey.withOpacity(0.2),
        offset: Offset(0, 5),
        blurRadius: 5,
        spreadRadius: 1)
    ],
        borderRadius: BorderRadius.circular(12),
        color: selected ? Colors.blue : Colors.grey),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWidget(
                    text: 'Standard',
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
                textWidget(
                    text: '\₹9.90',
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                textWidget(
                    text: '3 MIN',
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.normal,
                    fontSize: 12),
              ],
            ),
          ),
          Positioned(
              right: -20,
              top: 0,
              bottom: 0,
              child: Image.asset('assets/Mask Group 2.png'))
        ],
      ),
    );
  }
  String dropdownValue = '**** **** **** 8789';
  List<String> list = <String>[
    '**** **** **** 8789',
    '**** **** **** 8921',
    '**** **** **** 1233',
    '**** **** **** 4352'
  ];

  buildPaymentCardWidget() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/visa.png',
            width: 40,
          ),
          SizedBox(
            width: 10,
          ),
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.keyboard_arrow_down),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: textWidget(text: value),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
