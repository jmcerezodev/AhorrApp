import 'dart:io';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_shopping_list_item.dart';
import 'package:ahorrapp/data/repositories/isar_shopping_list_repository.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class MockLocalDbService extends Mock implements LocalDbService {}

void main() {
  late IsarShoppingListRepository repository;
  late MockLocalDbService mockLocalDb;
  late Isar isar;
  late String tempPath;

  setUpAll(() async {
    tempPath = p.join(Directory.current.path, 'test_db_shopping_qa');
    final dir = Directory(tempPath);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (e) {
        // Ignorar si el archivo está bloqueado
      }
    }
    if (!dir.existsSync()) dir.createSync(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [LocalShoppingItemSchema],
      directory: tempPath,
    );
  });

  tearDownAll(() async {
    await isar.close();
  });

  setUp(() async {
    mockLocalDb = MockLocalDbService();
    when(() => mockLocalDb.isar).thenReturn(isar);
    
    await getIt.reset();
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    
    repository = IsarShoppingListRepository();
    isar.writeTxnSync(() => isar.clearSync());

    // Stub para que el mock use la instancia real de Isar en memoria
    when(() => mockLocalDb.saveShoppingListItems(any())).thenAnswer((inv) async {
      final items = inv.positionalArguments[0] as List<LocalShoppingItem>;
      await isar.writeTxn(() => isar.localShoppingItems.putAll(items));
    });

    when(() => mockLocalDb.getShoppingList(any())).thenAnswer((inv) async {
      final userId = inv.positionalArguments[0] as String;
      return await isar.localShoppingItems.filter().userIdEqualTo(userId).findAll();
    });

    when(() => mockLocalDb.deleteShoppingItemByAppwriteId(any())).thenAnswer((inv) async {
      final id = inv.positionalArguments[0] as String;
      await isar.writeTxn(() => isar.localShoppingItems.filter().appwriteIdEqualTo(id).deleteAll());
    });
  });

  group('IsarShoppingListRepository - QA Coverage Fixed', () {
    test('saveShoppingItem debe persistir un nuevo item en Isar', () async {
      const item = ShoppingListItem(
        id: 'shop_1',
        userId: 'u1',
        name: 'Leche',
        amount: 1.5,
        category: 'Lácteos',
        isBought: false,
        position: 0,
        quantity: 2,
      );

      await repository.saveShoppingItem(item);

      final count = await isar.localShoppingItems.count();
      expect(count, 1);
      
      final saved = await isar.localShoppingItems.filter().appwriteIdEqualTo('shop_1').findFirst();
      expect(saved?.name, 'Leche');
    });

    test('getShoppingList debe retornar items ordenados por posición', () async {
      final i1 = LocalShoppingItem()..appwriteId = '1'..userId = 'u1'..name = 'A'..position = 1..isBought=false..amount=0..category=''..quantity=1..createdAt=DateTime.now();
      final i2 = LocalShoppingItem()..appwriteId = '2'..userId = 'u1'..name = 'B'..position = 0..isBought=false..amount=0..category=''..quantity=1..createdAt=DateTime.now();

      await isar.writeTxn(() async {
        await isar.localShoppingItems.putAll([i1, i2]);
      });

      final results = await repository.getShoppingList('u1');

      expect(results, hasLength(2));
      expect(results.first.id, '2'); // Posición 0
    });

    test('toggleItemBought debe cambiar el estado de compra en la DB', () async {
      final item = LocalShoppingItem()..appwriteId = 'id_t'..userId = 'u1'..name = 'T'..isBought = false..amount=0..category=''..quantity=1..position=0..createdAt=DateTime.now();
      await isar.writeTxn(() async => await isar.localShoppingItems.put(item));

      await repository.toggleItemBought('id_t', true);

      final updated = await isar.localShoppingItems.filter().appwriteIdEqualTo('id_t').findFirst();
      expect(updated?.isBought, true);
    });
  });
}
