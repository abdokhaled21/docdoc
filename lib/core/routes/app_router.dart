import 'package:flutter/material.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/login/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/signup/presentation/pages/signup_page.dart';
import '../../features/auth/forgot/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/doctor_speciality_page.dart';
import '../../features/home/presentation/pages/recommendation_doctor_page.dart';
import '../../features/home/presentation/pages/doctors_by_specialization_page.dart';
import '../../features/home/presentation/pages/doctor_details_page.dart';
import '../../features/booking/presentation/pages/book_appointment_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../../features/home/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/settings_page.dart';
import '../../features/appointments/presentation/pages/my_appointments_page.dart';
import '../../features/home/presentation/pages/edit_profile_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String forgot = '/forgot-password';
  static const String doctorSpeciality = '/doctor-speciality';
  static const String recommendationDoctor = '/recommendation-doctor';
  static const String doctorsBySpecialization = '/doctors-by-specialization';
  static const String doctorDetails = '/doctor-details';
  static const String bookAppointment = '/book-appointment';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String myAppointments = '/my-appointments';
  static const String editProfile = '/edit-profile';
}

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> _routes = <String, WidgetBuilder>{
    AppRoutes.splash: (_) => const SplashPage(),
    AppRoutes.onboarding: (_) => const OnboardingPage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.home: (_) => const HomePage(),
    AppRoutes.doctorSpeciality: (_) => const DoctorSpecialityPage(),
    AppRoutes.recommendationDoctor: (_) => const RecommendationDoctorPage(),
    AppRoutes.doctorsBySpecialization: (_) => const DoctorsBySpecializationPage(),
    AppRoutes.doctorDetails: (_) => const DoctorDetailsPage(),
    AppRoutes.bookAppointment: (_) => const BookAppointmentPage(),
    AppRoutes.search: (_) => const SearchPage(),
    AppRoutes.profile: (_) => const ProfilePage(),
    AppRoutes.settings: (_) => const SettingsPage(),
    AppRoutes.myAppointments: (_) => const MyAppointmentsPage(),
    AppRoutes.signup: (_) => const SignupPage(),
    AppRoutes.forgot: (_) => const ForgotPasswordPage(),
    AppRoutes.editProfile: (_) => const EditProfilePage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    return _unknownRoute();
  }

  static Route<dynamic> _unknownRoute() {
    return MaterialPageRoute(builder: (_) => const SplashPage());
  }
}
