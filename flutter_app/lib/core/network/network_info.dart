import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// 网络连接信息检查
/// 
/// 用于检测设备的网络连接状态
@lazySingleton
class NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfo(this._connectivity);
  
  /// 检查是否有网络连接
  /// 
  /// 返回true表示有网络连接（WiFi、移动网络或以太网）
  /// 返回false表示无网络连接
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    
    // 检查是否连接到任何网络
    return result.any((connectivity) =>
        connectivity == ConnectivityResult.mobile ||
        connectivity == ConnectivityResult.wifi ||
        connectivity == ConnectivityResult.ethernet);
  }
  
  /// 获取当前网络连接类型
  Future<List<ConnectivityResult>> get connectionType async {
    return await _connectivity.checkConnectivity();
  }
  
  /// 监听网络连接状态变化
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
  
  /// 检查是否连接到WiFi
  Future<bool> get isConnectedToWiFi async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }
  
  /// 检查是否使用移动数据
  Future<bool> get isConnectedToMobile async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }
}

/// Connectivity模块配置
@module
abstract class ConnectivityModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();
}
