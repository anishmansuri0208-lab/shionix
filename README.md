# 🛍️ Shionix — Supabase Connected Website

## ⚡ 3 Steps mein live karo

---

### STEP 1 — Supabase Setup (5 min)

**1.1** [supabase.com](https://supabase.com) pe free account banao

**1.2** New Project banao:
- Name: `shionix`
- Password: koi strong password
- Region: Southeast Asia
- **Create Project** click karo

**1.3** SQL run karo:
- Left sidebar → **SQL Editor** → **New Query**
- `supabase-setup.sql` file Notepad mein kholo
- Poora content copy karke SQL Editor mein paste karo
- **Run** (green button) click karo → "Success" aayega

**1.4** Apni keys copy karo:
- Left sidebar → **Settings** → **API**
- **Project URL** copy karo (jaise: `https://abcxyz.supabase.co`)
- **anon public** key copy karo (bada sa code)

**1.5** Email confirmation band karo (testing ke liye):
- Left sidebar → **Authentication** → **Providers** → **Email**
- "Confirm email" toggle → **OFF** karo
- Save

---

### STEP 2 — Config Update (1 min)

`config.js` file Notepad mein kholo aur apni keys daalo:

```javascript
const SHIONIX_CONFIG = {
  supabaseUrl:  'https://TUMHARA-PROJECT.supabase.co',  // ← yahan daalo
  supabaseAnon: 'TUMHARI-ANON-KEY',                     // ← yahan daalo
}
```

Save karo. Bas! ✅

---

### STEP 3 — Vercel pe Deploy (2 min)

**3.1** [vercel.com](https://vercel.com) pe login karo

**3.2** GitHub pe push karo:
- Puri `shionix-website` folder GitHub pe upload karo
- (sirf index.html, config.js, README.md, 404.html, .nojekyll)

**3.3** Vercel mein:
- "New Project" → GitHub repo import karo
- Framework: **Other** select karo
- Deploy click karo

**3.4** Done! Website live ho jaayegi ✅

---

## 📁 Files

```
shionix-website/
├── index.html          ← Poora website (Supabase connected)
├── config.js           ← Sirf yahan keys daalo ✏️
├── supabase-setup.sql  ← Supabase mein run karo (once)
├── 404.html            ← Page not found
├── .nojekyll           ← GitHub Pages fix
└── README.md           ← Ye file
```

---

## 🔐 Kya kaam karega Supabase se?

| Feature | Pehle | Ab |
|---------|-------|-----|
| Products | Hardcoded | ✅ Database se live |
| Categories | Hardcoded | ✅ Database se live |
| User Login | Fake (localStorage) | ✅ Real Supabase Auth |
| User Signup | Fake | ✅ Real account banta hai |
| Orders | localStorage mein save | ✅ Supabase mein save |
| Order History | Fake data | ✅ Real orders dikhte hain |
| Contact Form | Kuch nahi hota | ✅ Supabase mein save |
| Newsletter | Kuch nahi hota | ✅ Supabase mein save |
| Forgot Password | Kaam nahi karta | ✅ Real email jaata hai |

---

## 🛒 Admin se Products Add Karna

1. Admin Dashboard (`shionix-admin`) mein login karo
2. Products section mein nayi product add karo
3. Customer website pe **automatically** show ho jaayegi!

(Dono same Supabase project use karein)

---

## ❓ Common Problems

**Products nahi dikh rahe?**
→ Supabase SQL run hua? Check karo → Table Editor → products

**Login kaam nahi kar raha?**
→ config.js mein sahi keys hain? Double check karo

**"Invalid API Key" error?**
→ anon key copy karte time poora copy kiya? Key mein space na ho

**Email confirmation pop-up aa raha hai?**
→ Authentication → Email → "Confirm email" OFF karo

---

## 📞 Support
WhatsApp: [wa.me/919876543210](https://wa.me/919876543210)
Email: support@shionix.in
