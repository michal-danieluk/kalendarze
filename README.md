# System zamawiania kalendarzy

Aplikacja internetowa do zbierania zamówień na kalendarze firmowe, która umożliwia:

- Składanie zamówień przez pracowników
- Zatwierdzanie zamówień przez przełożonych
- Eksport zamówień do Excela (całościowy lub częściowy)
- Panel administracyjny do zarządzania zamówieniami

## Wymagania

- Ruby 3.2+
- Rails 8.0+
- Node.js 18+
- PostgreSQL
- Redis

## Instalacja

1. Sklonuj repozytorium:
   ```
   git clone https://github.com/user/kalendarze.git
   cd kalendarze
   ```

2. Zainstaluj zależności:
   ```
   bundle install
   ```

3. Skonfiguruj bazę danych:
   ```
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. Uruchom serwer:
   ```
   bin/dev
   ```

5. Otwórz przeglądarkę:
   ```
   http://localhost:3000
   ```

6. (Opcjonalnie) Skonfiguruj Mailgun do wysyłania e-maili:
   Instrukcje konfiguracji znajdziesz w [dokumentacji Mailgun](doc/MAILGUN_SETUP.md)

## Domyślni użytkownicy

W trybie development dostępne są następujące konta testowe:

- Administrator: admin@kalendarze.pl / password
- Przełożony: supervisor@kalendarze.pl / password
- Pracownik 1: anna.nowak@kalendarze.pl / password
- Pracownik 2: marek.wisniewski@kalendarze.pl / password

## Funkcjonalności

- Autentykacja użytkowników (Devise)
- Zarządzanie rolami użytkowników (admin, przełożony, pracownik)
- Składanie zamówień na kalendarze
- Zatwierdzanie/odrzucanie zamówień przez przełożonych
- Automatyczne wysyłanie e-maili do managerów w celu zatwierdzenia zamówień
- Generowanie raportów i eksport do Excela
- Wyszukiwanie i filtrowanie zamówień
- Responsywny interfejs użytkownika (Tailwind CSS)

## Technologie

- Ruby on Rails 8.0
- Devise (autentykacja)
- Tailwind CSS (frontend)
- Hotwire (Turbo + Stimulus)
- PostgreSQL (baza danych)
- Redis (cache, ActionCable)
- Axlsx (eksport do Excela)
- Mailgun (wysyłka e-maili)

## Licencja

Ten projekt jest licencjonowany na warunkach MIT License - szczegóły w pliku LICENSE.