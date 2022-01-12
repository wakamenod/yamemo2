import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/utils/log.dart';
import 'memo_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MemoServiceSQLite extends MemoService {
  static const _tblMemo = "Memo";
  static const _tblCategory = "Category";

  List<Memo>? _memos;
  List<MemoCategory>? _categories;
  Database? _database;

  static final migrationScripts = {
    '2': [
      'ALTER TABLE $_tblCategory ADD COLUMN sort_no INTEGER NOT NULL DEFAULT 0;',
      'UPDATE $_tblCategory SET sort_no = id;'
    ],
    // '3' : ['ALTER TABLE memo ADD COLUMN update_at TIMESTAMP;'],
  };

  Future<Database> get database async {
    if (_database != null) return _database!;

    Database d = await initDB();
    _database = d;
    return d;
  }

  Future<List<Memo>> get memos async {
    if (_memos != null) return _memos!;

    final db = await database;
    var res = await db.query(_tblMemo, orderBy: "id");

    List<Memo> list =
        res.isNotEmpty ? res.map((c) => Memo.fromMap(c)).toList() : [];

    return _memos = list;
  }

  Future<List<MemoCategory>> get categories async {
    if (_categories != null) return _categories!;

    final db = await database;
    var res = await db.query(_tblCategory, orderBy: "sort_no");

    List<Memo> listMemo = await memos;
    List<MemoCategory> list = res.isNotEmpty
        ? res.map((c) => MemoCategory.fromMap(c, listMemo)).toList()
        : [];

    LOG.info('get categories list=$list');
    return _categories = list;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), "yamemoapp_database.db");

    return await openDatabase(path, version: 2, onCreate: _createTable,
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
      LOG.info('old: $oldVersion new:$newVersion');
      for (var i = oldVersion + 1; i <= newVersion; i++) {
        var queries = migrationScripts[i.toString()];
        for (String query in queries!) {
          await db.execute(query);
        }
      }
    });
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute("CREATE TABLE Memo ("
        "id INTEGER PRIMARY KEY,"
        "category_id INTEGER,"
        "content TEXT"
        ")");
    await db.execute("CREATE TABLE Category ("
        "id INTEGER PRIMARY KEY,"
        "title TEXT"
        ")");
    await db.execute("INSERT INTO Category (title) VALUES('category1')");
    await db.execute("INSERT INTO Category (title) VALUES('category2')");
    for (var i = 1; i <= migrationScripts.length; i++) {
      var queries = migrationScripts[(i + 1).toString()];
      for (String query in queries!) {
        await db.execute(query);
      }
    }
  }

  @override
  Future<List<MemoCategory>> getAllCategories(bool forceDiskFetch) async {
    if (forceDiskFetch) {
      _categories = null;
      _memos = null;
    }
    return categories;
  }

  @override
  Future<List<Memo>> getAllMemos() {
    return memos;
  }

  @override
  Future<MemoCategory> addCategory(MemoCategory category) async {
    final db = await database;

    category.sortNo = _categories!.last.sortNo + 1;

    int id = await db.insert(
      _tblCategory,
      category.toMap(),
    );
    return MemoCategory(
        id: id, title: category.title, memos: [], sortNo: category.sortNo);
  }

  @override
  Future<Memo> addMemo(Memo memo) async {
    final db = await database;

    int id = await db.insert(
      _tblMemo,
      memo.toMap(),
    );
    return Memo(id: id, content: memo.content, categoryID: memo.categoryID);
  }

  @override
  Future deleteMemo(int id) async {
    final db = await database;

    var res = db.delete(_tblMemo, where: "id = ?", whereArgs: [id]);
    return res;
  }

  @override
  Future updateMemo(Map<String, dynamic> memoMap) async {
    final db = await database;

    var res = db
        .update(_tblMemo, memoMap, where: "id = ?", whereArgs: [memoMap["id"]]);
    return res;
  }

  @override
  Future updateCategorySortNos(int from, int to) async {
    final db = await database;

    if (from > to) {
      return await db.rawQuery(
          'UPDATE $_tblCategory SET sort_no = sort_no + 1 WHERE sort_no < ? AND sort_no >= ?',
          [from, to]);
    } else if (to > from) {
      return await db.rawQuery(
          'UPDATE $_tblCategory SET sort_no = sort_no - 1 WHERE sort_no > ? AND sort_no <= ?',
          [from, to]);
    }
  }

  @override
  Future updateCategory(MemoCategory category) async {
    final db = await database;

    var res = db.update(_tblCategory, category.toMap(),
        where: "id = ?", whereArgs: [category.id]);
    return res;
  }

  @override
  Future deleteCategory(MemoCategory category) async {
    final db = await database;

    await db.rawQuery(
        'UPDATE $_tblCategory SET sort_no = sort_no - 1 WHERE sort_no > ?',
        [category.sortNo]);

    var res =
        db.delete(_tblCategory, where: "id = ?", whereArgs: [category.id]);
    return res;
  }

  @override
  Future deleteMemoByCategoryID(int categoryID) async {
    final db = await database;

    var res =
        db.delete(_tblMemo, where: "category_id = ?", whereArgs: [categoryID]);
    return res;
  }
}
