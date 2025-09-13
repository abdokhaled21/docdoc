class Endpoints {
  Endpoints._();

  static const String baseUrl = 'https://vcare.integration25.com/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  static const String userProfile = '/user/profile';
  static const String userUpdate = '/user/update';

  static const String homeIndex = '/home/index';

  static const String specializationIndex = '/specialization/index';
  static const String specializationShow = '/specialization/show';

  static const String doctorIndex = '/doctor/index';
  static const String doctorFilter = '/doctor/doctor-filter';
  static const String doctorSearch = '/doctor/doctor-search';
  static const String doctorShow = '/doctor/show';

  static const String appointmentStore = '/appointment/store';
  static const String appointmentIndex = '/appointment/index';
}
