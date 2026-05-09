import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: {
        translation: {
          "login_title": "Sign in to your account",
          "email_label": "Email address",
          "password_label": "Password",
          "signin_button": "Sign in",
          "signing_in": "Signing in..."
        }
      }
    },
    lng: "en",
    fallbackLng: "en",
    interpolation: {
      escapeValue: false
    }
  });

export default i18n;
