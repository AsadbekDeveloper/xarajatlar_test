# Hisob bo'lishish

Do'stlar, oila a'zolari yoki hamkasblar o'rtasidagi o'zaro xarajatlarni qulay va oson taqsimlashga mo'ljallangan mobil ilova. Ilova har bir ishtirokchining sof balansini (kim kimdan qancha olishi yoki kimga qancha berishi kerakligini) hisoblab chiqadi va o'zaro qarzlarni **eng kam o'tkazmalar soni** bilan yopish uchun optimal tranzaksiyalar ro'yxatini ko'rsatadi.

Ilova jami ikkita ekrandan iborat: **Xarajatlar** (ro'yxatni ko'rish, yangi xarajat qo'shish, tahrirlash va o'chirish) hamda **Yakuniy hisob** (ishtirokchilar balansi va optimal o'tkazmalar).

Loyiha [`CLAUDE.md`](./CLAUDE.md) yo'riqnomasida belgilangan qoidalarga to'liq amal qilgan holda ishlab chiqilgan: "feature-first" (funksiyaga asoslangan) tuzilma, `flutter_bloc`/Cubit holat boshqaruvi va Material 3 dizayn tizimi.

## Skrinshotlar

Real qurilmada bosqichma-bosqich bajarilgan sinov jarayonidan namunalar: yangi xarajat qo'shish, jarayon davomida yangi ishtirokchini kiritish hamda yakuniy hisob-kitob natijalari.

| Xarajat qo'shish | Yangi ishtirokchi kiritish | Ishtirokchi qo'shilgach |
|---|---|---|
| ![Xarajat qo'shish oynasi](screenshots/add_sheet.png) | ![Yangi ishtirokchi nomi kiritilmoqda](screenshots/add_person.png) | ![Yangi ishtirokchi ro'yxatga qo'shildi](screenshots/new_person.png) |

| Xarajatlar ro'yxati | Yakuniy hisob |
|---|---|
| ![To'rtta xarajat bilan Xarajatlar ekrani](screenshots/home.png) | ![Balanslar va to'lovlar ro'yxati bilan Yakuniy hisob ekrani](screenshots/summary.png) |

Yuqoridagi misolda: Aziz, Bek va Dilnoza (boshlang'ich uch kishi) ustiga xarajat qo'shish jarayonida **Doston** yangi ishtirokchi sifatida qo'shilgan — buning uchun alohida "Odamlar" ekraniga o'tmasdan, to'g'ridan-to'g'ri shu oynaning o'zidan foydalanilgan. To'rtta xarajat (turli to'lovchi va qatnashchilar bilan jami 145 000, 32 000, 96 000 va 45 000 so'm) yakuniy hisobda uchta minimal to'lovga ("Bek → Aziz", "Doston → Aziz", "Doston → Dilnoza") keltiriladi — ya'ni to'rt kishi uchun ko'pi bilan `n-1 = 3` ta tranzaksiya amalga oshiriladi.

## Loyihani ishga tushirish

Loyiha kodini yuklab olgach, quyidagi buyruqlar yordamida uni ishga tushirishingiz mumkin:

```bash
flutter pub get
flutter run              # yoki brauzerda sinash uchun: flutter run -d chrome
flutter analyze
flutter test
```

*Eslatma:* Loyihada backend qismi va ma'lumotlarni doimiy saqlash (persistence) mexanizmi mavjud emas — topshiriq shartiga ko'ra, barcha ma'lumotlar faqatgina ilova ishlayotgan vaqtda tezkor xotirada (RAM) saqlanadi.

## Arxitektura va papkalar tuzilishi

Loyiha kodi quyidagicha tizimlashtirilgan:

```
lib/
  core/                          # Ilova mavzusi (theme), masofa/radius tokenlari, pul formatlash va snackbar kengaytmalari
  features/ledger/
    domain/                      # Sof Dart kodlari: Person va Expense modellari, xarajatlarni taqsimlash, balans va o'tkazmalarni hisoblash mantiqlari (UI'dan butunlay ajratilgan)
    data/                        # LedgerRepository interfeysi va uning xotiradagi (in-memory) implementatsiyasi
    cubit/                       # LedgerCubit va LedgerState (ilovadagi yagona ma'lumot manbasi)
    view/                        # ExpensesView, SummaryView va pastki navigatsiya xosti (LedgerHomePage)
    widgets/                     # Qayta ishlatiladigan UI komponentlari (formalar, chiplar, tile'lar)
test/domain/                     # Biznes mantiq (domain qatlami) uchun yozilgan unit testlar
```

`domain/` qatlami Flutter frameworkiga bog'liq bo'lmagani sababli, unit testlar juda tezkor va oson bajariladi.

## State Management (Holat boshqaruvi)

Ilova holatini boshqarish uchun **`flutter_bloc` / Cubit** kutubxonasi tanlandi. Ilovadagi ma'lumotlar oqimi asosan oddiy CRUD (qo'shish, tahrirlash, o'chirish) amallaridan iborat bo'lgani sababli, Cubit modeli ushbu vazifa uchun to'liq va yetarli deb topildi.

Har ikkala ekran ham yagona `LedgerCubit`dan foydalanadi. Ishtirokchilarning balansi va optimal to'lovlar esa holat (state) ichida saqlab o'tirilmaydi, balki joriy ma'lumotlar asosida **dinamik tarzda qayta hisoblab chiqiladi**. Bu yondashuv ma'lumotlarning eskirishi yoki o'zaro nomuvofiqligi (desenkronizatsiya) kabi xatolarning oldini oladi.

## Tizim mantiqi va algoritmlar

- **Teng taqsimlash (Equal split):** Summa guruh ishtirokchilari orasida dastlab `amount ~/ n` ko'rinishida butun qismlarga bo'linadi. Qolgan qoldiq esa ro'yxat bo'yicha boshidagi ishtirokchilarga 1 so'mdan taqsimlab chiqiladi. Bu yakuniy yig'indining umumiy summaga har doim 100% aniqlikda teng bo'lishini ta'minlaydi (matematik jihatdan isbotlangan va testlar orqali tasdiqlangan).
- **Minimal o'tkazmalar soni (Debt settlement):** Har bir qadamda eng katta kreditor (haqdor) va eng katta qarzdor aniqlanib, o'zaro bog'lanadi va ulardan birining balansi to'liq yopiladi (greedy/ochko'z algoritm). Bu ko'pi bilan `n-1` ta tranzaksiyani ta'minlaydi va berilgan topshiriq namunasidagi misolni (Aziz: +50 000, Bek: -10 000, Dilnoza: -40 000 → Dilnoza → Aziz: 40 000, Bek → Aziz: 10 000) aynan takrorlaydi.

  **Cheklovlar va o'zaro kelishuvlar (Trade-offs):** Greedy (ochko'z) algoritm har doim ham global miqyosdagi eng minimal tranzaksiyalar sonini kafolatlay olmaydi. Masalan, `test/domain/settlement_calculator_test.dart` faylida bunga yaqqol misol keltirilgan: 6 kishi ishtirokidagi holatda greedy algoritm 5 ta o'tkazma taklif qiladi, aslida esa qarzni 4 ta o'tkazma bilan yopish imkoni mavjud.
  Tranzaksiyalar sonining mutloq global minimal qiymatini topish NP-hard (murakkab) masala hisoblanib (LeetCode 465 — "Optimal Account Balancing"), u eksponensial vaqt oluvchi backtracking (ortga qaytish) algoritmini talab qiladi. Do'stlar guruhi kabi kichik jamoalar uchun biz tanlagan greedy yechim sodda, juda tez (`O(n log n)`) va real amaliyotda (masalan, mashhur Splitwise ilovasida) keng qo'llaniladigan eng optimal variantdir. Shuningdek, u topshiriqdagi asosiy talabni ("har bir qarzdorni har bir kreditorga alohida bog'lash noto'g'ri") to'liq qondiradi.

## Loyiha doirasidagi asosiy farazlar (Assumptions)

- **Ekran sarlavhasi:** Dizayn maketidagi "Sayohat" yozuvi shunchaki namuna sifatida ko'rsatilgan deb hisoblandi. Shu sababli, ekran sarlavhalari sifatida funksional nomlar ("Xarajatlar", "Yakuniy hisob") tanlandi. Ko'p guruhli (guruhlar ro'yxati mavjud bo'lgan) tizim topshiriq shartlarida so'ralmagan.
- **Boshlang'ich holat:** Tizimda oldindan 3 nafar ishtirokchi (Aziz, Bek, Dilnoza) mavjud, ammo xarajatlar ro'yxati bo'sh. Bu topshiriqdagi "bo'sh holat" (empty state) talabini qondiradi. Yangi ishtirokchini to'g'ridan-to'g'ri xarajat qo'shish oynasidan (sheet) kiritish imkoniyati yaratilgan.
- **Sinxron Repository:** Barcha operatsiyalar faqat xotirada (RAM) bajarilishi va kutilmagan xatoliklar yuz bermasligi sababli, repository qatlamida `Result<T>`/`Failure` o'ramlaridan foydalanib o'tirishga hojat qolmadi. Validatsiya ishlari Cubit va UI qatlamida amalga oshirilgan.
- **To'lovchi ishtirokchi bo'lmasligi:** To'lovni amalga oshirgan ishtirokchi xarajatdan ulushdor bo'lmasligi ham mumkin (masalan, butun guruh uchun ofis buyumlarini sotib olish) — bu holat balans hisob-kitobida to'liq qo'llab-quvvatlanadi (`test/domain/balance_calculator_test.dart`).
- **Doimiy saqlash (Persistence) qo'shilmadi:** Topshiriq shartlarida ma'lumotlarni doimiy saqlash majburiyati yo'qligi sababli u amalga oshirilmadi. Biroq, `LedgerRepository` interfeysi tayyor bo'lgani uchun kelajakda Local DB (Hive, Isar yoki Shared Preferences) ulash juda oson.

## Amalga oshirilgan bonus vazifalar

- **Tahrirlash va o'chirish imkoniyati:** Yagona `add_expense_sheet.dart` formasi xarajat qo'shish va tahrirlash uchun moslashtirilgan. Xarajat o'chirilganda, amalni bekor qilish imkonini beruvchi "Bekor qilish" (Undo) snackbar'i joriy etilgan.
- **Teng bo'lmagan (maxsus) taqsimot:** Ilovada xarajatlarni taqsimlashning "Teng" va "Maxsus" rejimlari mavjud. Maxsus rejimda har bir ishtirokchi uchun aniq xarajat ulushi qo'lda kiritiladi va tizim ulashlar yig'indisi umumiy summaga mos kelishini tekshiradi (`validateCustomShares`).

*Eslatma:* Loyiha asosan Google Chrome (Web) brauzerida sinovdan o'tkazildi, real Android/iOS qurilmalarida build qilinmadi (kod platformalarga xos bo'lmagan sof Flutter kodi hisoblanadi).

## AI (Claude) bilan ishlash tajribasi

**Asbob:** Loyihani rejalashtirish, kod yozish, testlash va mana shu yo'riqnomani (README) shakllantirishgacha bo'lgan barcha jarayonlarda Anthropic kompaniyasining Claude Code (Sonnet 5) asbobidan to'liq foydalanildi.

**AI qayerlarda va qanday ishlatildi:**
- **Dizayndan kodga o'tkazish:** `task.pdf` tarkibidagi mos referens rasm tahlil qilinib, ranglar palitrasi, masofalar va shrift o'lchamlari `lib/core/app_theme.dart` va `app_spacing.dart` fayllariga aniqlik bilan ko'chirildi.
- **Biznes mantiq va algoritmlar:** Pullarni aniq yaxlitlash (`expense_splitter.dart`), o'zaro balansni hisoblash (`balance_calculator.dart`) va optimal to'lovlarni shakllantirish (`settlement_calculator.dart`) algoritmlari AI ko'magida yozildi.
- **Refaktoring va debugging:** `flutter analyze` buyrug'i ko'rsatgan mayda ogohlantirishlar hamda quyida keltirilgan jiddiy mantiqiy xato o'z vaqtida bartaraf qilindi.
- **Keng qamrovli testlash:** Barcha `test/domain/*_test.dart` fayllari, jumladan, pullarni taqsimlash algoritmining to'g'riligini isbotlash uchun o'ta murakkab chegaraviy holatlar (0 so'mdan tortib 1 milliard so'mgacha, 1 tadan 10 tagacha ishtirokchi) bo'yicha test ssenariylari yaratildi.

**AI qayerda xatoga yo'l qo'ydi va u qanday tuzatildi (aniq misol):**
Dastlab optimal to'lovlarni hisoblash algoritmi (`calculateSettlements`) ikki ko'rsatkichli (two-pointer) usul yordamida ishlab chiqilgan edi: qarzdorlar va kreditorlar ro'yxati boshida bir marta kamayish tartibida saralanib, keyin ikki tomondan ko'rsatkichlar siljitilib borilardi.

Biroq, AI sub-agenti tomonidan amalga oshirilgan chuqur tahlil shuni ko'rsatdiki, qisman yopilgan qoldiq balans (masalan, dastlabki 100 000 so'm haqdorlikdan 5 000 so'm qolgan qismi) navbatdagi ishtirokchilar balansidan kichik bo'lib qolishi mumkin. Ikki ko'rsatkichli usul esa joriy ro'yxat tartibini qayta ko'rib chiqmagani sababli, har bir iteratsiyada joriy "eng katta kreditor va eng katta qarzdorni o'zaro bog'lash" qoidasi buzilayotgan edi. Kod xatosiz ishlashi va standart testlardan muvaffaqiyatli o'tishi mumkin bo'lsa-da, bu algoritmning asl mohiyatiga to'g'ri kelmasdi va ba'zi vaziyatlarda ortiqcha tranzaksiyalar yuzaga kelishiga sabab bo'lardi.

**Tuzatish:** Algoritm har bir iteratsiyada qolgan balanslar ichidan eng katta kreditor va eng katta qarzdorni **dinamik ravishda qayta qidiradigan** ishonchli versiyaga o'zgartirildi (`settlement_calculator.dart`). Shundan so'ng, 6 kishidan iborat murakkab test holati (A: -2000, B: -2000, C: -5000, D: +8000, E: +5000, F: -4000) qo'lda tekshirilib, kutilgan natija to'liq tasdiqlandi. Ushbu ssenariy endi `settlement_calculator_test.dart` tarkibida regressiya testi (regression test) sifatida saqlanmoqda.

**AI bilan ishlashda qo'llanilgan aniq so'rov (prompt):**
> "Given a mutable map of balances... verify this greedy algorithm against the reference example... try to construct a concrete small counterexample... give a final recommendation: greedy vs exact DFS backtracking."

Ushbu tahliliy jarayon natijasida ochko'z (greedy) algoritmni mutloq aniq bo'lgan, ammo juda sekin ishlovchi va murakkab NP-hard backtracking usuliga qarshi solishtirgan holda, **greedy yechimni ongli ravishda tanladim** va buni kod izohlarida hamda yuqoridagi "Tizim mantiqi" bo'limida shaffof tarzda (yashirmasdan) hujjatlashtirdim.

## Qo'shimcha ishlov: dizayn patternlari va CI/CD (keyingi bosqich)

Topshiriq topshirilgandan so'ng, kodni shunchaki "ishlaydigan" darajadan "diqqat bilan loyihalangan" darajaga ko'tarish uchun Claude Code bilan qo'shimcha bir bosqich o'tkazildi. Har bir qo'shimcha aniq muammoni yechish uchun tanlandi — hech bir pattern shunchaki ko'rgazma uchun qo'shilmadi:

- **Mixin** (`core/disposable_controllers_mixin.dart`): uchta widget (`AddExpenseSheet`, `ParticipantSelector`, `CustomSplitEditor`) da takrorlangan "`TextEditingController` yaratish → unutmasdan `dispose()` qilish" andozasini bitta joyga jamladi.
- **DRY**: uchta joyda takrorlangan `listEquals`-asosidagi `buildWhen` tekshiruvlari `ledger_state.dart`dagi `ledgerPeopleChanged`/`ledgerDataChanged` funksiyalariga ko'chirildi — "state nima o'zgarganda hisoblanadi" degan qoida endi bitta joyda saqlanadi.
- **CI** (`.github/workflows/ci.yml`): har bir push/PR uchun `dart format`, `flutter analyze`, `flutter test` buyruqlari avtomatik ravishda ishga tushadi.

**Sinab ko'rilib, so'ngra voz kechilgan narsalar** (va nima uchun?):
- **Strategy pattern** (`domain/split_strategy.dart` sifatida) — Teng va Maxsus bo'linish uchun ixtiyoriy `Map<String,int>? customShares` parametri o'rniga `SplitStrategy` interfeysi (`EqualSplitStrategy`/`CustomSplitStrategy`) sinab ko'rildi. Qayta tahlil qilish jarayonida aniqlandiki, `CustomSplitStrategy` interfeysning o'z `amount`/`participantIds` parametrlarini butunlay e'tiborsiz qoldirar edi — bu ikki implementatsiya aslida bir xil shaklga ega emasligini, demak interfeys haqiqiy abstraktsiya rolini o'ynamayotganini ko'rsatdi. Shuning uchun bu patterndan voz kechildi va oddiy hamda tushunarli bo'lgan `customShares` parametriga qaytildi.
- **Decorator pattern** (`data/logging_ledger_repository.dart` sifatida) — debug rejimida har bir o'zgarishni logga yozib boruvchi `LoggingLedgerRepository` sinab ko'rildi. Biroq, topshiriqning baholash mezonlarida audit/kuzatuv tizimi so'ralmagani sababli, bu qo'shimcha kodbazaga ortiqcha hajm va murakkablik qo'shgani uchun olib tashlandi.

**Loyihaga ongli ravishda qo'shilmagan narsalar** (va nima uchun?):
- **Factory pattern** — repository'ning faqat bitta haqiqiy implementatsiyasi (`InMemoryLedgerRepository`) bor; shu sababli Factory qo'shish hech qanday muammoni yechmagan holda faqat murakkablik qo'shgan bo'lardi.
- **GoF State pattern** (`LedgerState` uchun) — barcha repository amallari sinxron va xatosiz bo'lgani sababli, unda yuklanish (loading) yoki xatolik (error) holatlari umuman yo'q. Shu bois State pattern bu yerda o'zini oqlamadi.
- **`Money` qiymat turi** (`int` o'rniga) — butun kodbaza va testlar bo'ylab tarqaladigan ulkan o'zgarish bo'lardi, vaholanki valyuta o'zgarmas (faqat o'zbek so'mi) va mavjud `int`-asosidagi invariantlar allaqachon testlar bilan to'liq qamrab olingan.
- **Umumiy test-fixture/builder moduli** — har bir test fayli o'z `Person`/`Expense` obyektlarini mustaqil yaratadi. Bu kodning ozgina takrorlanishiga olib kelsa-da, testlarni bir-biridan mustaqil va tushunarli qiladi (chunki, umumiy fixture'ga kiritilgan o'zgarish boshqa aloqasiz testlarni kutilmaganda buzishi mumkin — "DAMP over DRY" testlash falsafasi).

Ushbu ro'yxat ham sun'iy intellekt bilan hamkorlik qilishning bir qismidir: AI'dan nafaqat kod yozish va patternlarni sinab ko'rishni, balki **qaysi yechimlar mos kelmasligini tanib, ulardan o'z vaqtida voz kechishni** ham so'radim. Kodning shunchaki ishlashi yetarli emas; har bir qo'shimcha murakkablik o'zini oqlashi shart.
