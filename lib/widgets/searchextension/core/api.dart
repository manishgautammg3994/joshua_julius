import 'dart:convert';
import ''; //please import http
//please import that Search Model
import '../models/search_model.dart';

Future<List<Searchmodel>> addressSuggestion(String searchText,
    {int limitInformation = 5}) async {
  var data;
  final response = await http
      .post(Uri.parse('https://example.com/api/library/search'), body: {
    'Keyword': searchText,
  });
//   Response response = await Dio().post(
//       // "http://maps.google.com/maps?q=jhojhu" //working
//       //'https://maps.googleapis.com/maps/api/place/findplacefromtext/output?parameters', //
//       "https://example.com/api/library/search",
// //      "https://maps.googleapis.com/maps/api/place/textsearch/json?query=123%20main%20street&key=YOUR_API_KEY",
// // queryParameters: {
// //       "query": searchText,
// //       "key": YOUR_API_KEY,
// //     },
//       // queryParameters: {
//       //   "q": searchText,
//       //   "limit": limitInformation == 0 ? "" : "$limitInformation"
//       // },
//       body: {
//         'Keyword': searchText,
//       });
  if (response.statusCode == 200) {
    final json = response.body
      ..toString()
          .replaceAll("\n", ""); //please for better response provide regex
    data = jsonDecode(json); //encode

  }

  // final json = response.data;
  return (data["success"]
          as List) //TODO make sure data is In List form //dataType of API
      .map((category) => Searchmodel.fromJson(category))
      .toList();
}
