/**
 * [유틸] 폰번호 포맷
 */
String formatPhoneNumber(String phoneNumber) {
  if (phoneNumber.length == 11) {
    return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
  }
  return phoneNumber;
}

/**
 * [유틸] 날짜 포맷
 */
String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  String year = parsedDate.year.toString();
  String month = parsedDate.month.toString().padLeft(2, '0'); // 01, 02 형태로
  String day = parsedDate.day.toString().padLeft(2, '0'); // 01, 02 형태로
  return '$year년 $month월 $day일'; // 형식화된 문자열 반환
}

String? formatDateYYYYMMDD(DateTime? date) {
  if (date == null) {
    return null; // date가 null인 경우 null 반환
  }
  return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
}

/**
 * [유틸] 금액 포맷
 */
String formatCash(String cash) {
  // 문자열을 숫자로 변환하고 쉼표를 추가
  String buffer = '';
  int length = cash.length;

  for (int i = 0; i < length; i++) {
    buffer += cash[i];
    // 뒤에서부터 3자리마다 쉼표 추가
    if ((length - i - 1) % 3 == 0 && (length - i - 1) != 0) {
      buffer += ',';
    }
  }

  return buffer;
}