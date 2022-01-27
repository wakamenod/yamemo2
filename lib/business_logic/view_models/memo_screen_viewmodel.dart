import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/services/memo/memo_service.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/utils/log.dart';

class MemoScreenViewModel extends ChangeNotifier {
  final MemoService _memoService = serviceLocator<MemoService>();
  List<MemoCategory> _categories = [];
  List<Memo> _memos = [];
  bool isLoading = true;
  Future<List<MemoCategory>>? futureCategories;
  MemoCategory _selectedCategory = MemoCategory.nullCategory;
  Memo _selectedMemo = Memo.nullMemo;

  void loadData() async {
    LOG.info('loadData');
    isLoading = true;
    _categories = await _memoService.getAllCategories(true);

    if (_categories.isEmpty) {
      addCategory("New Category");
    }

    _selectedCategory = _isCategorySelected()
        ? getCategoryByID(_selectedCategory.id)
        : _categories[0];

    isLoading = false;
    notifyListeners();
  }

  bool _isCategorySelected() {
    return !identical(_selectedCategory, MemoCategory.nullCategory);
  }

  int get categoryCount {
    return _categories.length;
  }

  MemoCategory getCategoryAt(int idx) {
    return _categories[idx];
  }

  MemoCategory getCategoryByID(int categoryID) {
    for (var category in _categories) {
      if (category.id == categoryID) {
        return category;
      }
    }
    throw AssertionError();
  }

  Memo getMemoByID(int memoID) {
    return _memos.firstWhere((element) => element.id == memoID,
        orElse: () => Memo.nullMemo);
  }

  Future deleteCategory(MemoCategory category) async {
    var indexOfCategory = _categories.indexOf(category);
    MemoCategory nextSelectedCategory;
    nextSelectedCategory = indexOfCategory == categoryCount - 1
        ? getCategoryAt(indexOfCategory - 1)
        : getCategoryAt(indexOfCategory + 1);
    await _memoService.deleteMemoByCategoryID(category.id);
    await _memoService.deleteCategory(category);

    selectCategoryByID(nextSelectedCategory.id);

    loadData();
  }

  Future deleteMemo(Memo memo) async {
    final memoId = memo.id;
    if (memoId == null) {
      return;
    }

    var cat = getCategoryByID(memo.categoryID);
    await _memoService.deleteMemo(memoId);
    cat.memos.remove(memo);
    notifyListeners();
  }

  List<MemoCategory> get categories {
    return _categories;
  }

  MemoCategory get selectedCategory {
    return _selectedCategory;
  }

  bool isSelectedCategory(MemoCategory c) {
    return c == _selectedCategory;
  }

  int get indexOfSelectedCategory {
    return _categories.indexOf(_selectedCategory);
  }

  void selectCategoryAt(int index) {
    selectCategory(getCategoryAt(index));
  }

  void selectCategoryByID(int id) {
    selectCategory(getCategoryByID(id));
  }

  void selectCategory(MemoCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future addCategory(String title) async {
    var res = await _memoService
        .addCategory(MemoCategory(id: 0, sortNo: 0, title: title, memos: []));
    _categories.add(res);
    selectCategory(res);
    notifyListeners();
  }

  Future updateCategory(String title, int sortNo) async {
    if (sortNo != _selectedCategory.sortNo) {
      final from = _selectedCategory.sortNo;
      final to = sortNo;
      await _memoService.updateCategorySortNos(from, to);
    }

    _selectedCategory.title = title;
    _selectedCategory.sortNo = sortNo;
    await _memoService.updateCategory(_selectedCategory);

    loadData();
  }

  Future<Memo> addMemo(String content) async {
    var selectedCategoryID = _selectedCategory.id;
    var res = await _memoService
        .addMemo(Memo(content: content, categoryID: selectedCategoryID));
    _selectedCategory.memos.add(res);
    notifyListeners();
    return res;
  }

  Future updateSelectedMemo(String content) async {
    var categoryID = _selectedCategory.id;

    var memoMap = _selectedMemo.toMap();
    memoMap["content"] = content;
    memoMap["category_id"] = categoryID;

    await _memoService.updateMemo(memoMap).catchError((e) {
      LOG.warn(e);
      throw e;
    }).whenComplete(() {
      loadData();
    });
  }

  Memo get selectedMemo {
    return _selectedMemo;
  }

  bool isMemoSelected() {
    return _selectedMemo != Memo.nullMemo;
  }

  void selectMemo(Memo memo) {
    _selectedMemo = memo;
    notifyListeners();
  }

  void deselectMemo() {
    _selectedMemo = Memo.nullMemo;
    notifyListeners();
  }

  @override
  Future updateWritingMemoRecord(int memoID) async {
    return _memoService.updateWritingMemoRecord(memoID);
  }

  @override
  Future<int> getWritingMemoID() async {
    return _memoService.getWritingMemoID();
  }
}
