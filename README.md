# Hisob bo'lishish

Do'stlar birga xarajat qiladi — har xarajatni bittasi to'laydi, lekin bir nechtasiga
tegishli bo'ladi. Ilova har kishining sof balansini (oladi/beradi) hisoblab, hisobni
**eng kam sonli to'lov** bilan yopish uchun kerakli tranzaksiyalarni ko'rsatadi.

Ikki ekran: **Xarajatlar** (ro'yxat + qo'shish/tahrirlash/o'chirish) va **Yakuniy hisob**
(balanslar + to'lovlar ro'yxati).

Loyiha [`CLAUDE.md`](./CLAUDE.md) dagi konventsiyalarga amal qiladi — feature-first
tuzilish, `flutter_bloc`/Cubit, Material 3.

## Ishga tushirish

```bash
flutter pub get
flutter run              # yoki: flutter run -d chrome
flutter analyze
flutter test
```

Backend, autentifikatsiya va persistence yo'q — barcha ma'lumot ilova ishlayotgan vaqtda
xotirada saqlanadi (topshiriq shartiga ko'ra).

## Arxitektura va papka tuzilishi

```
lib/
  core/                          # theme, spacing/radius tokenlari, pul formatlash, snackbar extensionlari
  features/ledger/
    domain/                      # sof Dart: Person, Expense, split/balance/settlement funksiyalari — UI'dan butunlay ajratilgan
    data/                        # LedgerRepository interfeysi + xotiradagi implementatsiya
    cubit/                       # LedgerCubit + LedgerState — ikkala ekran ham shu bitta manbadan foydalanadi
    view/                        # ExpensesView, SummaryView, bottom-nav host
    widgets/                     # qayta ishlatiladigan UI qismlar (forma, chip'lar, tile'lar)
test/domain/                     # mantiq uchun unit testlar
```

`domain/` qatlami Flutter'ga bog'liq emas — faqat sof funksiyalar, shuning uchun to'liq
`flutter_test`siz ham tekshiriladi va tez ishlaydi.

## State management tanlovi

Loyiha konventsiyasiga ko'ra **`flutter_bloc` / Cubit** ishlatildi. Bu yerdagi holat —
oddiy CRUD (xarajat qo'shish/tahrirlash/o'chirish) bo'lib, murakkab event-transformer
(`debounce`, `droppable` va h.k.) kerak emas — Cubit'ning to'g'ridan-to'g'ri metod
chaqirish modeli yetarli. Ikkala ekran bitta `LedgerCubit`dan foydalanadi, chunki
ular bir xil ma'lumot (odamlar + xarajatlar) ustida ishlaydi; balans va to'lovlar esa
har safar shu ma'lumotdan **hisoblab chiqiladi** (state ichida saqlanmaydi) — shunda
eskirgan/mos kelmaydigan holat paydo bo'lishi mumkin emas.

## Mantiq: yaxlitlash va eng kam to'lov

- **Teng bo'lish.** `amount ~/ n` + qoldiqni ro'yxat tartibida birinchi ishtirokchilarga
  1 so'mdan tarqatish — yig'indi har doim aniq `amount`ga teng chiqadi (0 dan katta
  har qanday summa va ishtirokchilar soni uchun isbotlangan va testlangan).
- **Eng kam to'lov.** Har safar eng katta kreditor va eng katta qarzdorni bir-biriga
  bog'lab, ularning kichigini yopamiz (greedy). Bu — har qarzdorni har kreditorga
  alohida bog'lashdan (topshiriqda noto'g'ri deb ko'rsatilgan yechim) farqli ravishda —
  har doim ko'pi bilan `n-1` ta tranzaksiya beradi va dizayn namunasidagi misolni
  (Aziz +50 000, Bek −10 000, Dilnoza −40 000 → Dilnoza→Aziz 40 000, Bek→Aziz 10 000)
  aniq takrorlaydi.

  **Ongli chegara:** bu greedy yechim har doim global minimal sonini kafolatlamaydi —
  `test/domain/settlement_calculator_test.dart` da buni ko'rsatadigan aniq misol bor
  (6 kishi, greedy 5 ta to'lov beradi, aniq yechim 4 tasi bilan yopishi mumkin edi).
  Global minimumni kafolatlash NP-hard masala (LeetCode 465 — "Optimal Account
  Balancing") va eksponensial backtracking talab qiladi. Do'stlar guruhi kabi kichik
  hajmli amaliy holat uchun bu — sodda, tez (`O(n log n)`) va sanoatda keng qo'llaniladigan
  (Splitwise shu yondashuvni ishlatadi) yechim, shu bilan birga topshiriqning asosiy
  talabini ("har qarzdorni har kreditorga bog'lash noto'g'ri") to'liq qondiradi.

## Farazlar

- **Ekran sarlavhasi.** Dizayn namunasidagi "Sayohat" — bitta misol safar nomi
  (dekorativ), ilova esa umumiy "hisob bo'lishish" vositasi bo'lgani uchun sarlavha
  sifatida ekran nomi ("Xarajatlar") ishlatildi. Ko'p-safar/guruh funksiyasi
  topshiriqda so'ralmagan.
- **Boshlang'ich holat.** 3 kishi (Aziz, Bek, Dilnoza — dizayn namunasidagi ismlar)
  oldindan mavjud, lekin xarajatlar ro'yxati bo'sh — shunda talab qilingan "bo'sh"
  holat ilova ochilganda darhol ko'rinadi. Yangi ishtirokchi xarajat qo'shish
  formasidan to'g'ridan-to'g'ri qo'shiladi (alohida "odamlar" ekrani yo'q).
- **Repository — sinxron, `Result<T>`siz.** Loyiha konventsiyasi (`.claude/patterns/models.md`)
  repository chegarasida `Result<T>`/`Failure` ishlatishni belgilaydi — bu tarmoq/DB
  xatoliklari uchun mo'ljallangan. Bu yerda ma'lumot butunlay xotirada va mutatsiyalar
  hech qachon muvaffaqiyatsiz bo'lmaydi, shuning uchun `Result` o'rash — sabab bo'lmagan
  xatolikni ifodalash uchun ortiqcha murakkablik bo'lar edi. Foydalanuvchi kiritgan
  ma'lumot validatsiyasi (bo'sh nom, 0 dan kichik summa, ishtirokchi tanlanmagani,
  noto'g'ri maxsus ulush) forma/cubit qatlamida oddiy xabar sifatida amalga oshirilgan.
- **To'lovchi ishtirokchi bo'lmasligi mumkin.** Masalan, "ofis uchun men to'ladim,
  lekin men qatnashmayman" — mantiqiy jihatdan to'g'ri va balans hisobida qo'llab-quvvatlanadi
  (`test/domain/balance_calculator_test.dart`da testlangan).

## Bonus qismlar (barchasi amalga oshirilgan)

- **Xarajatni tahrirlash va o'chirish** — bitta forma (`add_expense_sheet.dart`) ham
  qo'shish, ham tahrirlash uchun ishlatiladi; o'chirishda "Bekor qilish" snackbar'i bilan
  qaytarish imkoniyati bor.
- **Teng bo'lmagan bo'linish** — "Teng" / "Maxsus" almashtirgich; maxsus rejimda har
  ishtirokchi uchun aniq summa kiritiladi, yig'indi umumiy summaga aniq teng bo'lishi
  talab qilinadi (`validateCustomShares`).

Vaqt tejash uchun chegaralangan qism: ilova faqat web (Chrome)da qo'lda tekshirildi;
Android/iOS qurilmada haqiqiy build orqali sinov o'tkazilmadi (kod platformaga xos emas,
lekin fizik qurilmada tasdiqlash qoldirilgan).

## AI bilan ishlash

**Vosita:** Claude Code (Anthropic, Sonnet 5) — loyihaning boshidan oxirigacha, arxitektura
rejalashtirishdan tortib kodlash, testlash va shu README yozishgacha.

**Qayerda ishlatildi:**
- **Dizayn → kod:** `task.pdf` dagi referens rasm tahlil qilinib, ranglar/radius/shrift
  tokenlari `lib/core/app_theme.dart`, `app_spacing.dart` ga aniq mos qilib ko'chirildi.
- **Mantiq:** yaxlitlash (`expense_splitter.dart`), balans (`balance_calculator.dart`) va
  eng kam to'lov (`settlement_calculator.dart`) algoritmlari.
- **Refactor/debug:** `flutter analyze` orqali topilgan kichik lint xatolari (masalan,
  string interpolyatsiyasidagi keraksiz `{}`) va bir marta topilgan haqiqiy mantiqiy xato
  (pastda tavsiflangan) tuzatildi.
- **Test:** barcha `test/domain/*_test.dart` fayllari — jumladan pul yaxlitlash uchun
  keng qamrovli (0 dan 1 milliardgacha summa × 1–10 ishtirokchi) tekshiruv.

**AI qayerda xato qildi va qanday tuzatildi (aniq misol):**

Dastlabki `calculateSettlements` implementatsiyasi ikki ko'rsatkichli (two-pointer)
usul bilan yozilgan edi: kreditorlar va qarzdorlar ro'yxati bir marta kamayish tartibida
saralanib, keyin faqat "boshidan" siljitilardi. Alohida so'ralgan tekshiruv (murakkab
holatlarni qidiruvchi sub-agent) shuni ko'rsatdiki — qisman to'langan qoldiq (masalan,
100 000 dan 5 000 qolgani) keyingi navbatdagi kattaroq balansdan kichik bo'lib qolishi
mumkin, lekin ikki-ko'rsatkichli usul buni qayta hisoblamaydi, natijada tavsiflangan
"eng katta kreditor va eng katta qarzdorni bog'lash" qoidasi buzilardi. Bu — kod ishlaydi
va testdan o'tishi ham mumkin edi, lekin izohlangan algoritmga mos kelmasdi va noto'g'ri
holatlarda ko'proq tranzaksiya berishi mumkin edi.

**Tuzatish:** algoritm har iteratsiyada joriy eng katta kreditor/qarzdorni **qayta
qidiradigan** (bitta marta saralash o'rniga) versiyaga almashtirildi (`settlement_calculator.dart`).
Shundan so'ng qo'lda 6 kishilik holat (A:-2000, B:-2000, C:-5000, D:+8000, E:+5000, F:-4000)
bilan tekshirilib, natija sub-agentning kutilgan izlanishi bilan solishtirildi va mos
kelishi tasdiqlandi — bu holat endi `settlement_calculator_test.dart`da regressiya testi
sifatida saqlangan.

**Ishlatilgan aniq prompt (qisqartirilgan):**

> "Given a mutable map of balances... verify this greedy algorithm against the reference
> example... try to construct a concrete small counterexample... give a final
> recommendation: greedy vs exact DFS backtracking."

Bu so'rov orqali men (AI yordamida) ongli ravishda **greedy algoritmni tanladim**, uni
NP-hard aniq yechimga qarshi solishtirib — va bu tanlovni kod izohida hamda yuqoridagi
"Mantiq" bo'limida shaffof tarzda hujjatlashtirdim, uni yashirmasdan.
