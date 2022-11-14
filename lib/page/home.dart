import 'package:carrot_market/repository/contents_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ContentRepository contentRepository;
  final oCcy = NumberFormat("#,###", "ko_KR");
  String currentLocation = 'toukyou';
  final Map<String, String> locationTypeToString = {
    "toukyou": "東京",
    "sinzyuku": "新宿",
    "sibuya": "渋谷",
    "akihabara": "秋葉原"
  };

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    contentRepository = ContentRepository();
  }

  String calcStringToWon(String priceString) {
    if (priceString == '무료나눔') {
      return priceString;
    }
    final won = oCcy.format(int.parse(priceString));
    return '$won원';
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: GestureDetector(
        onTap: () {},
        child: PopupMenuButton<String>(
          offset: const Offset(0, 25),
          shape: ShapeBorder.lerp(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              1),
          onSelected: (String value) {
            print(value);
            setState(() {
              currentLocation = value;
            });
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(value: "toukyou", child: Text('東京')),
              const PopupMenuItem(value: "sinzyuku", child: Text('新宿')),
              const PopupMenuItem(value: "sibuya", child: Text('渋谷')),
              const PopupMenuItem(value: "akihabara", child: Text('秋葉原')),
            ];
          },
          child: Row(
            children: [
              Text(locationTypeToString[currentLocation]!),
              Icon(
                Icons.arrow_drop_down,
              )
            ],
          ),
        ),
      ),
      elevation: 1,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            '/Users/wonjongseo/Desktop/MY/coding/learing-v2/flutter/flutter_application_1/carrot_market/assets/svg/bell.svg',
            width: 22,
          ),
        ),
      ],
    );
  }

  _loadContent() {
    return contentRepository.loadContentsFromLocation(currentLocation);
  }

  Widget _makeDataList(dynamic datas) {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (BuildContext _context, int index) {
          return GestureDetector(
            onTap: () {
              print(datas[index]['title']);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  // 모서리 각
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.asset(
                      datas[index]['image'].toString(),
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            datas[index]['title'].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(datas[index]['location'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.3),
                              )),
                          const SizedBox(height: 5),
                          Text(
                            calcStringToWon(datas[index]['price'].toString()),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SvgPicture.asset(
                                  '/Users/wonjongseo/Desktop/MY/coding/learing-v2/flutter/flutter_application_1/carrot_market/assets/svg/heart_off.svg',
                                  width: 13,
                                  height: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(datas[index]['likes'].toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext _context, int index) {
          return Container(
            height: 1,
            color: Colors.black.withOpacity(0.4),
          );
        },
        itemCount: datas.length);
  }

  Widget _bodyWidget() {
    return FutureBuilder<List<Map<String, String>>>(
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Data Error');
        }
        if (snapshot.hasData) {
          return _makeDataList(snapshot.data!);
        }

        return const CircularProgressIndicator();
      },
      future: _loadContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }

  // }
}
