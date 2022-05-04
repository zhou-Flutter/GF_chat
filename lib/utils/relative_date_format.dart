class RelativeDateFormat {
  static String timeToBefore(int createTime) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(createTime * 1000);
    int ms =
        DateTime.now().millisecondsSinceEpoch - time.millisecondsSinceEpoch;

    // 如果是今天,则直接标出时间
    if (ms <= 86400000) {
      String hour = time.hour < 10
          ? 0.toString() + time.hour.toString()
          : time.hour.toString();
      String second = time.second < 10
          ? 0.toString() + time.second.toString()
          : time.second.toString();
      return hour + ":" + second;
    } else if (ms <= 172800000) {
      return "昨天";
    } else if (ms <= 259200000) {
      return "前天";
    } else if (ms <= 604800000) {
      // 七天以内
      switch (time.weekday) {
        case 1:
          return "星期一";
        case 2:
          return "星期二";
        case 3:
          return "星期三";
        case 4:
          return "星期四";
        case 5:
          return "星期五";
        case 6:
          return "星期六";
        case 7:
          return "星期日";
        default:
          return "未知日期";
      }
    } else {
      String month = time.month < 10
          ? 0.toString() + time.month.toString()
          : time.month.toString();
      String day = time.day < 10
          ? 0.toString() + time.day.toString()
          : time.day.toString();

      // 直接年月日
      return time.year.toString() + "-" + month + "-" + day;
    }
  }

  static String chatTime(int createTime) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(createTime * 1000);
    int ms =
        DateTime.now().millisecondsSinceEpoch - time.millisecondsSinceEpoch;
    String hour = time.hour < 10
        ? 0.toString() + time.hour.toString()
        : time.hour.toString();
    String minute = time.minute < 10
        ? 0.toString() + time.minute.toString()
        : time.minute.toString();
    // 如果是今天,则直接标出时间
    if (ms <= 86400000) {
      return hour + ":" + minute;
    } else if (ms <= 172800000) {
      return "昨天 " + hour + ":" + minute;
    } else if (ms <= 604800000) {
      // 七天以内
      switch (time.weekday) {
        case 1:
          return "星期一 " + hour + ":" + minute;
        case 2:
          return "星期二 " + hour + ":" + minute;
        case 3:
          return "星期三 " + hour + ":" + minute;
        case 4:
          return "星期四 " + hour + ":" + minute;
        case 5:
          return "星期五 " + hour + ":" + minute;
        case 6:
          return "星期六 " + hour + ":" + minute;
        case 7:
          return "星期日 " + hour + ":" + minute;
        default:
          return "未知日期";
      }
    } else {
      String month = time.month < 10
          ? 0.toString() + time.month.toString()
          : time.month.toString();
      String day = time.day < 10
          ? 0.toString() + time.day.toString()
          : time.day.toString();

      // 直接年月日
      return time.year.toString() + "-" + month + "-" + day;
    }
  }

  // 分钟 ： 秒数 时间
  static String soundTime(int millise) {
    String minute = "00:00";
    if (millise < 60) {
      var m = millise < 10 ? "0$millise" : "$millise";
      minute = "00:$m";
    } else if (millise < 120) {
      int mi = millise - 60;
      var m = mi < 10 ? "0$mi" : "$mi";
      minute = "01:$m";
    } else if (millise < 180) {
      int mi = millise - 120;
      var m = mi < 10 ? "0$mi" : "$mi";
      minute = "02:$m";
    }
    return minute;
  }
}
