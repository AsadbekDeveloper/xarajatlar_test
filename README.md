# Hisob Bo'lishish

Do'stlar yoki hamkasblar o'rtasidagi o'zaro xarajatlarni oson taqsimlash uchun mo'ljallangan mobil ilova. Ilova har bir ishtirokchining sof balansini (kim qancha olishi yoki berishi kerakligini) hisoblab, o'zaro qarzlarni **eng kam to'lovlar soni** bilan yopish uchun optimal tranzaksiyalarni ko'rsatadi.

Ilova ikki ekrandan iborat: **Xarajatlar** (ro'yxat, qo'shish, tahrirlash, o'chirish) va **Yakuniy hisob** (balanslar va optimal o'tkazmalar).

Loyiha [`CLAUDE.md`](./CLAUDE.md) qoidalariga to'liq amal qiladi: "feature-first" tuzilma, `flutter_bloc`/Cubit va Material 3 dizayni.

## Loyihani ishga tushirish

```bash
flutter pub get
flutter run              # yoki: flutter run -d chrome
flutter analyze
flutter test
```

*Eslatma:* Backend va ma'lumotlarni doimiy saqlash (persistence) qismi mavjud emas — barcha ma'lumotlar ilova ishlayotgan vaqtda faqat operativ xotirada (RAM) saqlanadi (topshiriq shartiga ko'ra).

## Arxitektura va papka tuzilishi

```
lib/
  core/                          # Mavzu (theme), masofa/radius tokenlari, pul formatlash, snackbar kengaytmalari
  features/ledger/
    domain/                      # Sof Dart: Person, Expense modellar, split/balance/settlement mantiqlari (UI'dan ajratilgan)
    data/                        # LedgerRepository interfeysi va in-memory implementatsiyasi
    cubit/                       # LedgerCubit va LedgerState (yagona ma'lumot manbasi)
    view/                        # ExpensesView, SummaryView va pastki navigatsiya xosti
    widgets/                     # Qayta ishlatiladigan UI komponentlari (forma, chiplar, tile'lar)
test/domain/                     # Biznes mantiq (domain) uchun unit testlar
```

`domain/` qatlami Flutter'ga bog'liq bo'lmagani uchun testlar tezkor va oson bajariladi.

## State Management

Holatni boshqarish uchun **`flutter_bloc` / Cubit** tanlandi. Ilovadagi ma'lumotlar oqimi oddiy CRUD (qo'shish, tahrirlash, o'chirish) amallaridan iborat bo'lgani sababli, Cubit modeli to'liq yetarli deb topildi. 

Ikkala ekran yagona `LedgerCubit`dan foydalanadi. Balans va optimal to'lovlar esa state ichida saqlanmasdan, har safar ma'lumotlar asosida **dinamik ravishda qayta hisoblab chiqiladi**. Bu ma'lumotlar eskirishi yoki mos kelmay qolishining (desenkronizatsiya) oldini oladi.

## Tizim mantiqi va algoritmlar

- **Teng taqsimlash (Equal split):** Summa guruh ishtirokchilari orasida dastlab `amount ~/ n` ko'rinishida butun bo'linadi. Qoldiq esa ro'yxat bo'yicha birinchi ishtirokchilarga 1 so'mdan taqsimlanadi. Bu yakuniy yig'indini umumiy summaga har doim aniq teng bo'lishini ta'minlaydi (matematik isbotlangan va testlar bilan tasdiqlangan).
- **Minimal o'tkazmalar soni (Debt settlement):** Har safar eng katta kreditor (haqdor) va eng katta qarzdor o'zaro bog'lanib, kichigining balansi to'liq yopiladi (greedy/ochko'z algoritm). Bu ko'pi bilan `n-1` ta tranzaksiyani ta'minlaydi va dizayn namunasidagi misolni (Aziz +50 000, Bek -10 000, Dilnoza -40 000 → Dilnoza → Aziz: 40 000, Bek → Aziz: 10 000) aynan takrorlaydi.

  **Cheklovlar (Trade-offs):** Greedy algoritm har doim ham global minimal tranzaksiyalar sonini kafolatlamaydi. Masalan, `test/domain/settlement_calculator_test.dart` faylida bunga yaqqol misol keltirilgan (6 kishi ishtirokidagi holatda greedy algoritm 5 ta o'tkazma taklif qiladi, aslida esa qarzni 4 ta o'tkazma bilan ham yopish mumkin edi).
  Tranzaksiyalar sonining mutloq global minimal qiymatini topish — NP-hard masala hisoblanadi (LeetCode 465 — "Optimal Account Balancing") va u eksponensial vaqt oluvchi backtracking (ortga qaytish) algoritmini talab qiladi. Do'stlar guruhi kabi kichik guruhlar uchun ushbu yechim sodda, juda tez (`O(n log n)`) va sanoatda (masalan, Splitwise ilovasida) keng qo'llaniladigan eng maqbul variantdir. Shuningdek, u topshiriqdagi asosiy talabni ("har bir qarzdorni har bir kreditorga alohida bog'lash noto'g'ri") to'liq qondiradi.

## Loyiha doirasidagi farazlar (Assumptions)

- **Ekran sarlavhasi:** Dizayndagi "Sayohat" shunchaki dekorativ namuna bo'lgani uchun sarlavha sifatida ekranlarning funksional nomlari ("Xarajatlar", "Yakuniy hisob") ishlatildi. Ko'p guruhli tizim topshiriqda so'ralmagan.
- **Boshlang'ich holat:** Tizimda oldindan 3 nafar ishtirokchi (Aziz, Bek, Dilnoza) mavjud, ammo xarajatlar ro'yxati bo'sh. Bu topshiriqdagi "bo'sh holat" (empty state) talabini qondiradi. Yangi ishtirokchini xarajat qo'shish oynasidan (sheet) to'g'ridan-to'g'ri qo'shish mumkin.
- **Sinxron Repository:** Barcha operatsiyalar faqat xotirada bajarilishi va xatolik yuz bermasligi sababli, repository qatlamida `Result<T>`/`Failure` o'ramlaridan foydalanilmadi. Validatsiya ishlari Cubit va UI qatlamida bajarilgan.
- **To'lovchi ishtirokchi bo'lmasligi:** To'lovni amalga oshirgan ishtirokchi xarajatdan ulushdor bo'lmasligi ham mumkin (masalan, ofis uchun to'lov) — bu holat balans hisob-kitobida to'liq qo'llab-quvvatlanadi (`test/domain/balance_calculator_test.dart`).
- **Persistence qo'shilmadi:** Topshiriq shartlariga ko'ra ma'lumotlarni saqlash majburiy emasligi sababli joriy doirada amalga oshirilmadi. Biroq, `LedgerRepository` interfeysi tayyor bo'lgani uchun kelajakda saqlash mexanizmini ulash oson.

## Amalga oshirilgan bonus vazifalar

- **Tahrirlash va o'chirish:** Yagona `add_expense_sheet.dart` formasi qo'shish va tahrirlash uchun ishlatiladi. Xarajat o'chirilganda amallarni qaytarish imkonini beruvchi "Bekor qilish" (Undo) snackbar'i mavjud.
- **Teng bo'lmagan (maxsus) taqsimot:** "Teng" va "Maxsus" rejimlar mavjud. Maxsus rejimda har bir ishtirokchi uchun aniq xarajat ulushi qo'lda kiritiladi va tizim ulashlar yig'indisi umumiy summaga mosligini validatsiya qiladi (`validateCustomShares`).

*Eslatma:* Loyiha Google Chrome (Web) brauzerida sinovdan o'tkazildi, real Android/iOS qurilmalarida build qilinmadi (kod platformaga xos emas).

## AI (Claude) bilan ishlash tajribasi

**Asbob:** Claude Code (Anthropic, Sonnet 5) — tizim arxitekturasini loyihalashtirishdan tortib, kod yozish, testlash va mana shu qo'llanmani (README) shakllantirishgacha bo'lgan barcha jarayonlarda to'liq foydalanildi.

**Qayerda ishlatildi (AI breakdown):**
- **Dizayndan kodga o'tkazish:** `task.pdf` tarkibidagi mos referens rasm tahlil qilinib, ranglar palitrasi, masofalar va shrift o'lchamlari `lib/core/app_theme.dart` va `app_spacing.dart` fayllariga aniqlik bilan ko'chirildi.
- **Biznes mantiq (algoritmlar):** Pullarni aniq yaxlitlash (`expense_splitter.dart`), o'zaro balansni hisoblash (`balance_calculator.dart`) va optimal to'lovlarni shakllantirish (`settlement_calculator.dart`) algoritmlari AI ko'magida yozildi.
- **Refaktoring va debugging:** `flutter analyze` buyrug'i ko'rsatgan mayda ogohlantirishlar (masalan, matn ichidagi keraksiz `{}` qavslar) hamda quyida keltirilgan jiddiy mantiqiy xato o'z vaqtida bartaraf qilindi.
- **Testlash (Testing):** Barcha `test/domain/*_test.dart` fayllari, jumladan, pullarni taqsimlash algoritmining to'g'riligini isbotlash uchun o'ta murakkab chegaraviy holatlar (0 so'mdan tortib 1 milliard so'mgacha, 1 tadan 10 tagacha ishtirokchi) bo'yicha keng qamrovli test ssenariylari yaratildi.

**AI qayerda xatoga yo'l qo'ydi va u qanday tuzatildi (aniq misol):**
Dastlab optimal to'lovlarni hisoblash algoritmi (`calculateSettlements`) ikki ko'rsatkichli (two-pointer) usul yordamida ishlab chiqilgan edi: qarzdorlar va kreditorlar ro'yxati boshida bir marta kamayish tartibida saralanib, keyin ikki tomondan ko'rsatkichlar siljitilib borilardi.

Biroq, AI sub-agenti tomonidan amalga oshirilgan chuqur tahlil shuni ko'rsatdiki, qisman yopilgan qoldiq balans (masalan, dastlabki 100 000 so'm haqdorlikdan 5 000 so'm qolgan qismi) navbatdagi ishtirokchilar balansidan kichik bo'lib qolishi mumkin. Ikki ko'rsatkichli usul esa tartibni qayta ko'rib chiqmagani sababli, har bir iteratsiyada joriy "eng katta kreditor va eng katta qarzdorni o'zaro bog'lash" qoidasi buzilayotgan edi. Kod xatosiz ishlashi va standart testlardan muvaffaqiyatli o'tishi mumkin bo'lsa-da, bu algoritmning asl mohiyatiga to'g'ri kelmasdi va ba'zi vaziyatlarda ortiqcha tranzaksiyalar yuzaga kelishiga sabab bo'lardi.

**Tuzatish:** Algoritm har bir iteratsiyada qolgan balanslar ichidan eng katta kreditor va eng katta qarzdorni **dinamik ravishda qayta qidiradigan** ishonchli versiyaga o'zgartirildi (`settlement_calculator.dart`). Shundan so'ng, 6 kishidan iborat murakkab test holati (A: -2000, B: -2000, C: -5000, D: +8000, E: +5000, F: -4000) qo'lda tekshirilib, kutilgan natija to'liq tasdiqlandi. Ushbu ssenariy endi `settlement_calculator_test.dart` tarkibida regressiya testi (regression test) sifatida saqlanmoqda.

**AI bilan ishlashda qo'llanilgan aniq so'rov (prompt):**
> "Given a mutable map of balances... verify this greedy algorithm against the reference example... try to construct a concrete small counterexample... give a final recommendation: greedy vs exact DFS backtracking."

Ushbu tahliliy jarayon natijasida (AI bilan hamkorlikda) ochko'z (greedy) algoritmni mutloq aniq bo'lgan, ammo juda sekin ishlovchi va murakkab NP-hard backtracking usuliga qarshi solishtirgan holda, **greedy yechimni ongli ravishda tanladim** va buni kod izohlarida hamda yuqoridagi "Tizim mantiqi" bo'limida shaffof tarzda (yashirmasdan) hujjatlashtirdim.
