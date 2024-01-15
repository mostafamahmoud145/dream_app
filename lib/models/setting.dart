


class Setting {
  String settingId;
  String? firstTitleAr;
  String? firstTitleEn;
  dynamic androidVersion;
  dynamic androidBuildNumber;
  dynamic appleVersion;
  dynamic appleBuildNumber;
  dynamic iosVersion;
  dynamic iosBuildNumber;
  dynamic taxes;
  String? focalDestination;

  Setting({
    required this.settingId,
    this.firstTitleAr,
    this.firstTitleEn,
    this.androidVersion,
    this.androidBuildNumber,
    this.appleVersion,
    this.appleBuildNumber,
    this.iosVersion,
    this.iosBuildNumber,
    this.taxes,
    this.focalDestination,


  });

  factory Setting.fromMap(Map  data) {
    return Setting(
      settingId: data['settingId'],
      firstTitleAr: data['firstTitleAr'],
      firstTitleEn: data['firstTitleEn'],
      androidVersion: data['androidVersion'],
      androidBuildNumber: data['androidBuildNumber'],
      iosVersion: data['iosVersion'],
      iosBuildNumber: data['iosBuildNumber'],
      appleVersion: data['appleVersion'],
      appleBuildNumber: data['appleBuildNumber'],
      taxes: data['taxes'],
      focalDestination:data['focalDestination'],

    );
  }
}


