# Konfiguracja Mailgun dla systemu zamówień kalendarzy

Ten dokument zawiera instrukcje dotyczące konfiguracji Mailgun do wysyłania e-maili w systemie zamówień kalendarzy, w szczególności dla funkcji zatwierdzania zamówień przez managerów.

## 1. Rejestracja w Mailgun

1. Zarejestruj się na stronie [Mailgun](https://www.mailgun.com/)
2. Potwierdź swoją domenę lub użyj domeny sandbox (dla testów)
3. Znajdź i zanotuj swój klucz API oraz domenę

## 2. Dodanie poświadczeń Mailgun do aplikacji

Aby zapewnić bezpieczeństwo poświadczeń Mailgun, stosujemy zaszyfrowane zmienne środowiskowe za pomocą mechanizmu credentials w Rails.

### Dodawanie poświadczeń:

```bash
rails credentials:edit
```

W otwartym edytorze dodaj następujące informacje:

```yaml
# Dodaj te wartości do istniejącego pliku credentials.yml.enc
mailgun:
  api_key: "key-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  domain: "twoja-domena.mailgun.org"
```

Zapisz i zamknij edytor (w vim: naciśnij ESC, wpisz `:wq` i naciśnij Enter).

## 3. Konfiguracja w środowisku produkcyjnym

Konfiguracja dla środowiska produkcyjnego znajduje się już w pliku `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :mailgun
config.action_mailer.mailgun_settings = {
  api_key: Rails.application.credentials.dig(:mailgun, :api_key),
  domain: Rails.application.credentials.dig(:mailgun, :domain)
}
```

## 4. Konfiguracja w środowisku rozwojowym (opcjonalnie)

Dla środowiska dev, możesz skonfigurować Mailgun lub użyć wbudowanego w Rails mechanizmu do przechwytywania wiadomości e-mail.

Aby używać Mailgun w środowisku dev, dodaj poniższy kod do `config/environments/development.rb`:

```ruby
config.action_mailer.delivery_method = :mailgun
config.action_mailer.mailgun_settings = {
  api_key: Rails.application.credentials.dig(:mailgun, :api_key),
  domain: Rails.application.credentials.dig(:mailgun, :domain)
}
```

Aby używać lokalnego podglądu e-maili (bez faktycznego wysyłania):

```ruby
config.action_mailer.delivery_method = :letter_opener
```

(wymaga dodania gem'a `letter_opener` do Gemfile)

## 5. Testowanie konfiguracji

Aby przetestować konfigurację, można wykonać następujące kroki:

1. Otwórz konsolę Rails: `rails console`
2. Wykonaj następujący kod:

```ruby
# Znajdź istniejące zamówienie
order = Order.last
# Wyślij e-mail testowy
OrderMailer.manager_approval_request(order).deliver_now
```

## 6. Rozwiązywanie problemów

### Problem: E-maile nie są wysyłane

1. Sprawdź logi aplikacji w poszukiwaniu błędów: `tail -f log/production.log`
2. Sprawdź, czy klucz API i domena są poprawne
3. Sprawdź, czy domena została prawidłowo zweryfikowana w Mailgun
4. Sprawdź panel Mailgun, czy nie ma problemów z kontem lub ograniczeń

### Problem: E-maile są oznaczane jako spam

1. Skonfiguruj rekordy SPF i DKIM dla swojej domeny (instrukcje dostępne w panelu Mailgun)
2. Użyj domeny niestandardowej zamiast domeny sandbox
3. Upewnij się, że adresy e-mail nadawcy i odbiorcy są poprawne

## 7. Bezpieczeństwo

1. Nigdy nie przechowuj poświadczeń Mailgun w kodzie źródłowym
2. Regularnie zmieniaj klucz API Mailgun
3. Monitoruj wykorzystanie API w panelu Mailgun
4. Ogranicz dostęp do konta Mailgun tylko do niezbędnych osób

---

W przypadku pytań lub problemów, skontaktuj się z administratorem systemu.