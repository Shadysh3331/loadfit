import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loadfit/config/routes_manager/routes.dart';
import 'package:loadfit/config/routes_manager/routes_generator.dart';
import 'package:loadfit/core/cache/shared_pref.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.initialize();
  runApp(MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: child,
        onGenerateRoute: RoutesGenerator.getRoute,
        initialRoute: Routes.signInRoute ,
      ),

    );


  }
}
