/// Base URL of the Django web service.
///
/// Override at build/run time, e.g. for a local server on the Android emulator:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://elvis-sestomi-ui-kembali.pws.cs.ui.ac.id',
);
