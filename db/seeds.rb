# This file should create initial data for application testing

# Utworzenie użytkowników administracyjnych
admin = User.create!(
  email: 'admin@kalendarze.pl',
  password: 'password',
  name: 'Administrator',
  role: 'admin',
  department: 'IT'
)

# Utworzenie managerów (supervisorów)
manager_hr = User.create!(
  email: 'manager.hr@kalendarze.pl',
  password: 'password',
  name: 'Jan Kowalski',
  role: 'supervisor',
  department: 'HR'
)

manager_marketing = User.create!(
  email: 'manager.marketing@kalendarze.pl',
  password: 'password',
  name: 'Katarzyna Nowakowska',
  role: 'supervisor',
  department: 'Marketing'
)

manager_sales = User.create!(
  email: 'manager.sales@kalendarze.pl',
  password: 'password',
  name: 'Tomasz Lewandowski',
  role: 'supervisor',
  department: 'Sprzedaż'
)

manager_finance = User.create!(
  email: 'manager.finance@kalendarze.pl',
  password: 'password',
  name: 'Magdalena Dąbrowska',
  role: 'supervisor',
  department: 'Finanse'
)

# Utworzenie zwykłych użytkowników
user1 = User.create!(
  email: 'anna.nowak@kalendarze.pl',
  password: 'password',
  name: 'Anna Nowak',
  role: 'user',
  department: 'Marketing',
  supervisor: manager_marketing
)

user2 = User.create!(
  email: 'marek.wisniewski@kalendarze.pl',
  password: 'password',
  name: 'Marek Wiśniewski',
  role: 'user',
  department: 'Sprzedaż',
  supervisor: manager_sales
)

# Dodatkowi pracownicy HR
User.create!(
  email: 'zofia.kowalczyk@kalendarze.pl',
  password: 'password',
  name: 'Zofia Kowalczyk',
  role: 'user',
  department: 'HR',
  supervisor: manager_hr
)

User.create!(
  email: 'piotr.adamski@kalendarze.pl',
  password: 'password',
  name: 'Piotr Adamski',
  role: 'user',
  department: 'HR',
  supervisor: manager_hr
)

# Dodatkowi pracownicy Marketing
User.create!(
  email: 'karolina.zielinska@kalendarze.pl',
  password: 'password',
  name: 'Karolina Zielińska',
  role: 'user',
  department: 'Marketing',
  supervisor: manager_marketing
)

User.create!(
  email: 'adam.szymanski@kalendarze.pl',
  password: 'password',
  name: 'Adam Szymański',
  role: 'user',
  department: 'Marketing',
  supervisor: manager_marketing
)

# Dodatkowi pracownicy Sprzedaż
User.create!(
  email: 'aleksandra.wojcik@kalendarze.pl',
  password: 'password',
  name: 'Aleksandra Wójcik',
  role: 'user',
  department: 'Sprzedaż',
  supervisor: manager_sales
)

User.create!(
  email: 'michal.kaminski@kalendarze.pl',
  password: 'password',
  name: 'Michał Kamiński',
  role: 'user',
  department: 'Sprzedaż',
  supervisor: manager_sales
)

# Dodatkowi pracownicy Finanse
User.create!(
  email: 'barbara.lewandowska@kalendarze.pl',
  password: 'password',
  name: 'Barbara Lewandowska',
  role: 'user',
  department: 'Finanse',
  supervisor: manager_finance
)

User.create!(
  email: 'robert.kaczmarek@kalendarze.pl',
  password: 'password',
  name: 'Robert Kaczmarek',
  role: 'user',
  department: 'Finanse',
  supervisor: manager_finance
)

# Utworzenie kalendarzy
calendars = [
  {
    name: 'Kalendarz ścienny 2025',
    description: 'Kalendarz ścienny z widokami miast Polski. Format A3, papier kredowy 200g.',
    year: 2025,
    calendar_type: 'Ścienny',
    price: 29.99
  },
  {
    name: 'Kalendarz biurkowy 2025',
    description: 'Kalendarz biurkowy tygodniowy. Oprawa spiralowana, format A5.',
    year: 2025,
    calendar_type: 'Biurkowy',
    price: 19.99
  },
  {
    name: 'Kalendarz kieszonkowy 2025',
    description: 'Kalendarz kieszonkowy w twardej oprawie. Format A6.',
    year: 2025,
    calendar_type: 'Kieszonkowy',
    price: 9.99
  },
  {
    name: 'Kalendarz trójdzielny 2025',
    description: 'Kalendarz trójdzielny z widokami gór. Z przesuwnym okienkiem.',
    year: 2025,
    calendar_type: 'Trójdzielny',
    price: 24.99
  }
]

calendars.each do |calendar_attributes|
  Calendar.create!(calendar_attributes)
end

# Utworzenie zamówień
order1 = Order.create!(
  user: user1,
  status: 'pending'
)

OrderItem.create!(
  order: order1,
  calendar: Calendar.find_by(calendar_type: 'Ścienny'),
  quantity: 2
)

OrderItem.create!(
  order: order1,
  calendar: Calendar.find_by(calendar_type: 'Biurkowy'),
  quantity: 1
)

order2 = Order.create!(
  user: user2,
  status: 'pending'
)

OrderItem.create!(
  order: order2,
  calendar: Calendar.find_by(calendar_type: 'Trójdzielny'),
  quantity: 3
)

# Zamówienie zatwierdzone
order3 = Order.create!(
  user: user1,
  status: 'confirmed',
  confirmed_by: manager_marketing,
  confirmed_at: 1.day.ago
)

OrderItem.create!(
  order: order3,
  calendar: Calendar.find_by(calendar_type: 'Kieszonkowy'),
  quantity: 5
)

# Zamówienie odrzucone
order4 = Order.create!(
  user: user2,
  status: 'rejected',
  confirmed_by: manager_sales,
  confirmed_at: 2.days.ago
)

# Dodatkowe zamówienia dla nowych użytkowników
finance_user = User.find_by(email: 'barbara.lewandowska@kalendarze.pl')
hr_user = User.find_by(email: 'zofia.kowalczyk@kalendarze.pl')
marketing_user = User.find_by(email: 'adam.szymanski@kalendarze.pl')

# Zamówienie zatwierdzone dla pracownika finansów
order5 = Order.create!(
  user: finance_user,
  status: 'confirmed',
  confirmed_by: manager_finance,
  confirmed_at: 3.days.ago
)

OrderItem.create!(
  order: order5,
  calendar: Calendar.find_by(calendar_type: 'Biurkowy'),
  quantity: 3
)

OrderItem.create!(
  order: order5,
  calendar: Calendar.find_by(calendar_type: 'Trójdzielny'),
  quantity: 1
)

# Zamówienie oczekujące dla pracownika HR
order6 = Order.create!(
  user: hr_user,
  status: 'pending'
)

OrderItem.create!(
  order: order6,
  calendar: Calendar.find_by(calendar_type: 'Ścienny'),
  quantity: 2
)

OrderItem.create!(
  order: order6,
  calendar: Calendar.find_by(calendar_type: 'Kieszonkowy'),
  quantity: 4
)

# Zamówienie odrzucone dla pracownika marketingu
order7 = Order.create!(
  user: marketing_user,
  status: 'rejected',
  confirmed_by: manager_marketing,
  confirmed_at: 5.days.ago
)

OrderItem.create!(
  order: order7,
  calendar: Calendar.find_by(calendar_type: 'Trójdzielny'),
  quantity: 8
)

OrderItem.create!(
  order: order4,
  calendar: Calendar.find_by(calendar_type: 'Ścienny'),
  quantity: 10
)

puts "Pomyślnie utworzono testowe dane!"