import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockConnectivity extends Mock implements Connectivity {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}
