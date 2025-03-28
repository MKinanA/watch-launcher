import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String addZeros(int? number, [int minLength = 2]) => number != null ? '${'0' * (minLength - number.toString().length)}$number' : '?' * minLength;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [],
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(),
      ),
      home: WholeThing(),
    );
  }
}

class WholeThing extends StatefulWidget {
  const WholeThing({
    super.key,
  });

  @override
  State<WholeThing> createState() => _WholeThingState();
}

class _WholeThingState extends State<WholeThing> {
  late final PageController horizontalPageController;
  late final PageController verticalPageController;

  @override
  void initState() {
    super.initState();
    horizontalPageController = PageController(
      initialPage: 1,
    );
    verticalPageController = PageController(
      initialPage: 1,
    );
  }

  @override
  void dispose() {
    verticalPageController.dispose();
    horizontalPageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClockFace(),
              ],
            ),
          ),
          HorizontalPageView(
            wholeThingSetState: setState,
            horizontalPageController: horizontalPageController,
            verticalPageController: verticalPageController,
          )
        ],
      ),
    );
  }
}

class HorizontalPageView extends StatefulWidget {
  final Function wholeThingSetState;
  final PageController horizontalPageController;
  final PageController verticalPageController;

  const HorizontalPageView({
    required this.wholeThingSetState,
    required this.horizontalPageController,
    required this.verticalPageController,
    super.key,
  });

  @override
  State<HorizontalPageView> createState() => _HorizontalPageViewState();
}

class _HorizontalPageViewState extends State<HorizontalPageView> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: (() {
        try {
          return widget.verticalPageController.page?.round() ?? 1;
        } catch (e) {
          return 1;
        }
      })() != 1 ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
      controller: widget.horizontalPageController,
      scrollDirection: Axis.horizontal,
      children: [
        Container(
          color: Colors/*.fromRGBO(15, 15, 15, 1)*/.red,
        ),
        VerticalPageView(
          wholeThingSetState: widget.wholeThingSetState,
          verticalPageController: widget.verticalPageController,
          horizontalSetState: setState,
        ),
        Container(
          color: Colors/*.fromRGBO(15, 15, 15, 1)*/.green,
        ),
      ],
    );
  }
}

class VerticalPageView extends StatefulWidget {
  final Function wholeThingSetState;
  final PageController verticalPageController;
  final Function horizontalSetState;

  const VerticalPageView({
    required this.wholeThingSetState,
    required this.verticalPageController,
    required this.horizontalSetState,
    super.key,
  });

  @override
  State<VerticalPageView> createState() => _VerticalPageViewState();
}

class _VerticalPageViewState extends State<VerticalPageView> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      onPageChanged: (i) {
        try {
          widget.horizontalSetState(() {});
        } finally {}
      },
      physics: const PageScrollPhysics(),
      controller: widget.verticalPageController,
      scrollDirection: Axis.vertical,
      children: [
        Container(
          color: Colors/*.fromRGBO(15, 15, 15, 1)*/.yellow,
        ),
        SizedBox(),
        Container(
          color: Colors/*.fromRGBO(15, 15, 15, 1)*/.blue,
        ),
      ],
    );
  }
}

class ClockFace extends StatelessWidget {
  const ClockFace({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(
        const Duration(
          milliseconds: 100,
        ),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.active
        ? Column(
          children: [
            Text(
              '${addZeros(snapshot.data?.hour)}:${addZeros(snapshot.data?.minute)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 96.0,
                fontWeight: FontWeight.w700,
                height: 1.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              '${[
                'DAY',
                'MON',
                'TUE',
                'WED',
                'THU',
                'FRI',
                'SAT',
                'SUN',
              ][snapshot.data?.weekday ?? 0]} ${addZeros(snapshot.data?.day)}/${addZeros(snapshot.data?.month)}/${addZeros(snapshot.data?.year, 4)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w500,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        )
        : const CircularProgressIndicator(
          color: Colors.white,
        ),
    );
  }
}
