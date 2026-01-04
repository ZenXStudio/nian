/// 输入验证器
///
/// 提供常用的输入验证功能
class Validators {
  /// 验证邮箱格式
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    
    return null;
  }
  
  /// 验证密码强度
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    
    if (value.length < minLength) {
      return '密码长度至少为$minLength个字符';
    }
    
    return null;
  }
  
  /// 验证确认密码
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    
    if (value != password) {
      return '两次输入的密码不一致';
    }
    
    return null;
  }
  
  /// 验证必填项
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '请输入$fieldName' : '此项为必填项';
    }
    
    return null;
  }
  
  /// 验证手机号码（中国大陆）
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号码';
    }
    
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的手机号码';
    }
    
    return null;
  }
  
  /// 验证数字范围
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validateNumberRange(
    String? value, {
    required int min,
    required int max,
  }) {
    if (value == null || value.isEmpty) {
      return '请输入数字';
    }
    
    final number = int.tryParse(value);
    
    if (number == null) {
      return '请输入有效的数字';
    }
    
    if (number < min || number > max) {
      return '请输入$min到$max之间的数字';
    }
    
    return null;
  }
  
  /// 验证字符串长度
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return '请输入内容';
    }
    
    if (minLength != null && value.length < minLength) {
      return '长度至少为$minLength个字符';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '长度不能超过$maxLength个字符';
    }
    
    return null;
  }
  
  /// 验证URL
  ///
  /// 返回null表示验证通过，否则返回错误消息
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入URL';
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return '请输入有效的URL';
    }
    
    return null;
  }
  
  /// 组合多个验证器
  ///
  /// 返回第一个验证失败的错误消息
  static String? compose(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
