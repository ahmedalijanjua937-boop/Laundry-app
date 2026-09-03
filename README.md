# FreshCycle Laundry Flutter Frontend

Flutter frontend recreated from the public laundry app workflow.

## Run
1. Install Flutter 3.x.
2. Run `flutter pub get`.
3. Start the ASP.NET Core backend from the previous ZIP.
4. Android emulator: API is `http://10.0.2.2:5200/api`.
5. Physical Android device: replace `api` in `lib/main.dart` with your computer LAN IP, for example `http://192.168.1.10:5200/api`.
6. Run `flutter run`.

The backend remains ASP.NET Core Web API. This is a clean-room recreation, not the original private Lovable source code.
