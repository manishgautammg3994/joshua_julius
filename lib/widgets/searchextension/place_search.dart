import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../searchextension/core/api.dart';
import '../searchextension/models/search_model.dart';
// import '../speechtotext.dart';

class SearchWidget extends StatefulWidget {
  final bool isPopup;
  final bool autoFocus;
  final InputDecoration? decoration;
  final void Function(Searchmodel) onDone;
  final int suggestionLimit;
  final int minLengthToStartSearch;

  const SearchWidget(
      {Key? key,
      required this.onDone,
      this.isPopup = false,
      this.autoFocus = true, //changed from false
      this.decoration,
      this.suggestionLimit = 5,
      this.minLengthToStartSearch = 3})
      : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  ValueNotifier<GeoPoint?> notifierGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> notifierAutoCompletion = ValueNotifier(false);

  late StreamController<List<Searchmodel>> streamSuggestion =
      StreamController();
  late Future<List<Searchmodel>> _futureSuggestionAddress;
  String oldText = "";
  Timer? _timerToStartSuggestionReq;
  final Key streamKey = const Key("streamAddressSug");
  final TextEditingController controller = TextEditingController();
  String? text;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onSearchableTextChanged(String v) async {
    if (v.length > widget.minLengthToStartSearch && oldText != v) {
      oldText = v;
      if (_timerToStartSuggestionReq != null &&
          _timerToStartSuggestionReq!.isActive) {
        _timerToStartSuggestionReq!.cancel();
      }
      _timerToStartSuggestionReq =
          Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        await suggestionProcessing(v);
        timer.cancel();
      });
    }
    if (v.isEmpty) {
      await reInitStream();
    }
  }

  Future reInitStream() async {
    notifierAutoCompletion.value = false;
    await streamSuggestion.close();
    setState(() {
      streamSuggestion = StreamController();
    });
  }

  Future<void> suggestionProcessing(String addr) async {
    notifierAutoCompletion.value = true;
    _futureSuggestionAddress = addressSuggestion(
      addr,
      limitInformation: widget.suggestionLimit,
    );
    _futureSuggestionAddress.then((value) {
      streamSuggestion.sink.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: widget.isPopup
                  ? const EdgeInsets.all(10)
                  : const EdgeInsets.all(10),
              child: TextFormField(
                  controller: controller,
                  enableInteractiveSelection: false,
                  onChanged: onSearchableTextChanged,
                  autofocus: widget.autoFocus,
                  textAlign: TextAlign.justify,
                  decoration: InputDecoration(
                    prefixIcon: widget.isPopup
                        ? IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black))
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child:
                                const Icon(Icons.search, color: Colors.black),
                          ),
                    contentPadding: const EdgeInsets.all(5),
                    labelText: "Search",
                    suffixIcon: IconButton(
                        onPressed: toggleRecording,
                        icon: Icon(isListening ? Icons.hearing : Icons.mic_none,
                            color: Colors.black)),
                    // color: Colors.black))
                    //  widget.isPopup
                    // ? IconButton(
                    //     onPressed: () => Navigator.pop(context),
                    //     icon: const Icon(Icons.close, color: Colors.black))
                    // : Container()

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    focusColor: Theme.of(context).primaryColor,
                  )),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: notifierAutoCompletion,
              builder: (ctx, isVisible, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height:
                      isVisible ? MediaQuery.of(context).size.height / 4 : 0,
                  child: Card(
                    child: child!,
                  ),
                );
              },
              child: StreamBuilder<List<Searchmodel>>(
                stream: streamSuggestion.stream,
                key: streamKey,
                builder: (ctx, snap) {
                  if (snap.hasData && snap.data!.isNotEmpty) {
                    return ListView.builder(
                      itemExtent: 50.0,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(
                            snap.data![index].address.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          onTap: () async {
                            controller.text =
                                snap.data![index].address.toString();
                            log(snap.data![index].address.toString());
                            log(snap.data![index].point.toString());
                            widget.onDone(snap.data![index]);

                            /// hide suggestion card
                            notifierAutoCompletion.value = false;
                            await reInitStream();
                            FocusScope.of(context).requestFocus(
                              FocusNode(),
                            );
                          },
                        );
                      },
                      itemCount: snap.data!.length,
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Card(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }
                  if (snap.data!.isEmpty) {
                    return const Card(
                        child: Center(child: Text("No suggestion")));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
//in future product
  // Future toggleRecording() => SpeechApi.toggleRecording(
  //       onResult: (text) => setState(() => this.text = text),
  //       onListening: (isListening) {
  //         setState(() => this.isListening = isListening);

  //         if (!isListening) {
  //           Future.delayed(const Duration(milliseconds: 400), () {
  //             onSearchableTextChanged(text ?? oldText);
  //             controller.text = text ?? oldText;
  //           });
  //         }
  //       },
  //     );
}

enum Mode { overlay, fullscreen }

class PlaceAutocomplete {
  static show(
      {required BuildContext context,
      Mode mode = Mode.overlay,
      final bool autoFocus = false,
      final InputDecoration? textfieldDecoration,
      final Decoration? containerDecoration,
      final int suggestionLimit = 5,
      final int minLengthToStartSearch = 3,
      final EdgeInsetsGeometry? borderPadding,
      required Function(Searchmodel) onDone}) {
    // ignore: prefer_function_declarations_over_variables
    final builder = (BuildContext ctx) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: borderPadding ?? const EdgeInsets.all(8.0),
          child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: SearchWidget(
                onDone: onDone,
                suggestionLimit: suggestionLimit,
                minLengthToStartSearch: minLengthToStartSearch,
                isPopup: mode == Mode.overlay,
                autoFocus: autoFocus,
                decoration: textfieldDecoration,
              )),
        ));
    if (mode == Mode.overlay) {
      return showDialog(context: context, builder: builder);
    } else {
      return Navigator.push(context, MaterialPageRoute(builder: builder));
    }
  }

  static widget({
    required Function(Searchmodel) onDone,
    final bool autoFocus = false,
    final InputDecoration? textfieldDecoration,
    final int suggestionLimit = 5,
    final int minLengthToStartSearch = 3,
  }) {
    return SearchWidget(
      onDone: onDone,
      isPopup: false,
      autoFocus: autoFocus,
      decoration: textfieldDecoration,
      suggestionLimit: suggestionLimit,
      minLengthToStartSearch: minLengthToStartSearch,
    );
  }
}
