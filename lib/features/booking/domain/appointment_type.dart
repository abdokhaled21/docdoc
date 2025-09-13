enum AppointmentType {
  inPerson,
  videoCall,
  phoneCall,
}

extension AppointmentTypeX on AppointmentType {
  String get label {
    switch (this) {
      case AppointmentType.inPerson:
        return 'In Person';
      case AppointmentType.videoCall:
        return 'Video Call';
      case AppointmentType.phoneCall:
        return 'Phone Call';
    }
  }
}
