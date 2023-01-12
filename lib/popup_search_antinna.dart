

///////////////////////////////////////started//////////////////////////////
library popup_search_antinna;
import 'package:flutter/material.dart';
import 'package:livinghopegeetzaboor/Statemanagment/Library/LibraryProvider.dart';
import 'package:livinghopegeetzaboor/constant/AppColor.dart';
import 'package:livinghopegeetzaboor/sacreen/Geet/Geetsubcategory.dart';
import 'package:livinghopegeetzaboor/services/Services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import "../lib/widgets/searchextension/place_search.dart";

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: 100,
                  width: 100,
                  child: Image.asset('images/logo.png')),
              // Note: Same code is applied for the TextFormField as well
              // Note: Same code is applied for the TextFormField as well
              // Note: Same code is applied for the TextFormField as well
              Padding(
                padding: EdgeInsets.all(40),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: AppColor.color,
                  ),
                  height: 80,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                             readOnly: true,
                            controller: textController,
                             onTap: () => PlaceAutocomplete.show( context: context,onDone:(e){
                              ///Your Code Here
                              Navigator.pop(context);
                             })
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.search,
                                size: 40,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 2),
                              ),
                              filled: true, //<-- SEE HERE
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintText: 'Search for any songs',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        // Container(
                        //   height: 59,
                        //   width: 59,
                        //   color:Colors.white,
                        //   constraints: const BoxConstraints(
                        //
                        //   ),
                        //   // child: Icon(
                        //   //   Icons.search_sharp,
                        //   //   size: 40,
                        //   //   color: AppColor.color,
                        //   // ),
                        // )
                      ],
                    ),
                  ),
                ),
              ),

              Consumer<LibraryProvider>(
                builder: (BuildContext context, value, Widget? child) {
                  if (value.isloading) {
                    return CircularProgressIndicator(
                      color: AppColor.color,
                    );
                  } else {
                    return GridView.builder(
                      itemCount: value.library.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0),
                      itemBuilder: (BuildContext context, int index) {
                        var subtitle = value.library[index].name2;
                        return Padding(
                          padding: EdgeInsets.all(10),
                          child: Material(
                            color: Colors.white.withOpacity(0.0),
                            child: InkWell(
                              splashColor: Colors.orange,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.black,
                                ),

                                //color: Colors.black,
                                height: 200,
                                width: 200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Center(
                                        child: Text(
                                          value.library[index]!.name.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      child: Center(
                                          child: subtitle != null
                                              ? Text(
                                                  value.library[index].name2
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                )
                                              : Text(
                                                  '',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                )),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Geetsubcategory(
                                            id: value.library[index].id,
                                          )),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              )
            ],
          ),
          // your main content
        ),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).fetchlibary();

      // Add Your Code here.
    });
  }
}

