import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 方法Repository接口
///
/// 定义方法相关的数据访问接口
abstract class MethodRepository {
  /// 获取方法列表
  ///
  /// [category] 分类筛选（可选）
  /// [difficulty] 难度筛选（可选）
  /// [page] 页码
  /// [pageSize] 每页数量
  /// 返回 [List<Method>] 或 [Failure]
  Future<Either<Failure, List<Method>>> getMethods({
    String? category,
    String? difficulty,
    int page = 1,
    int pageSize = 20,
  });

  /// 获取方法详情
  ///
  /// [methodId] 方法ID
  /// 返回 [Method] 或 [Failure]
  Future<Either<Failure, Method>> getMethodDetail(int methodId);

  /// 搜索方法
  ///
  /// [keyword] 搜索关键词
  /// [page] 页码
  /// [pageSize] 每页数量
  /// 返回 [List<Method>] 或 [Failure]
  Future<Either<Failure, List<Method>>> searchMethods({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  });
}
