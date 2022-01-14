import 'package:flutter/material.dart';
import 'package:yamemo2/constants.dart';
// todo
// import 'package:yamemo2/services/admob/admob_service.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/ui/widgets/category_tab_bar.dart';
import 'package:yamemo2/ui/widgets/category_memo_list.dart';
// todo
// import 'package:admob_flutter/admob_flutter.dart';
import 'package:yamemo2/utils/log.dart'; // import the extension

class MemoListScreen extends StatefulWidget {
  static const id = 'list';

  const MemoListScreen({Key? key}) : super(key: key);

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen>
    with TickerProviderStateMixin {
  final _model = serviceLocator<MemoScreenViewModel>();
  // todo
  // final _ams = serviceLocator<AdMobService>();

  @override
  void initState() {
    _model.loadData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemoScreenViewModel>(
      create: (context) => _model,
      child: Consumer<MemoScreenViewModel>(builder: (context, value, child) {
        LOG.info('build memo list. isLoading=${value.isLoading}');
        if (value.isLoading) {
          return Container(
            color: kBaseBgColor,
          );
        }
        return Scaffold(
          appBar: AppBar(
              elevation: 0.0,
              backgroundColor: kBaseColor,
              // todo key
              bottom: CategoryTabBar(UniqueKey(), value)),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 50.0),
            child: FloatingActionButton(
                backgroundColor: kBaseColor,
                child: const Icon(Icons.add),
                onPressed: () async {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, anim1, anim2) =>
                          MemoDetailScreen(model: _model, screenType: ScreenType.add,),
                      transitionDuration: const Duration(seconds: 0),
                    ),
                  );
                }),
          ),
          body: Column(
            children: [
              Expanded(child: CategoryMemoList(UniqueKey(), value)),
              // todo
              // AdmobBanner(
              //   adSize: AdmobBannerSize.BANNER,
              //   adUnitId: _ams.getBannerAdID(),
              // )
            ],
          ),
        );
      }),
    );
  }
}
