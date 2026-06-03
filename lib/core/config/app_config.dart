class AppConfig {
  static const appUrl = String.fromEnvironment(
    'APP_URL',
    defaultValue: 'https://academypro-five.vercel.app',
  );

  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'salmanyousafzai312@gmail.com',
  );

  static const isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: true,
  );
}
