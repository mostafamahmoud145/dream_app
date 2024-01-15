String getPhoneWithoutCountryCode(String phoneNum, String countryCode){
  return phoneNum.replaceAll(countryCode, '');
}