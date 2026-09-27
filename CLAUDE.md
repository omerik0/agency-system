# ‏`CLAUDE.md` — הנחיות פרויקט ל-Claude Code

הצב קובץ זה בשורש תיקיית הפרויקט על ה-Mac mini. Claude Code טוען אותו אוטומטית כקונטקסט בכל סשן.

## מצב נוכחי (עדכון אחרון: 27.09.2026 20:10)
שלבים 0–2 הושלמו ואומתו (tags `stage1-verified`, `stage2-verified`). שלב 3 (קליטת לקוחות + הרחבת website-builder) הושלם בפועל — ממתין לאישור סופי של עומר לפני תיוג `stage3-verified`.
אתרים: רק `lak-ve-varak` (לקוח דמו משלבים 1–2) ו-`afik-gozland` (לקוח בדיקה), לצד `sites/_template-*`. guy-stauber‏, demo-shop-e2e‏, billing-demo הוסרו (דיסק, DB ראשי, Vercel‏, Supabase‏; מוצרי ה-Stripe test שלהם בארכיון). **ממתין ל"מאשר מחיקה"**: `sites/pinat-uri/` (דיסק+git) והסרת שלושת הקודמים מ-git.
לקוח בדיקה (ריצת זרימה מלאה, יימחק בהמשך): אפיק גוזלנד (`afik-gozland`, חנות + DB + Stripe cart) — רשום ב-`clients`/`projects` (project_id `932aaaab-e700-47a0-970e-ed986a3402b8`), פרויקט Supabase ‏`aykdajxqkxlflqruhebv` נוצר, 5 טבלאות עם RLS‏ (סכמה ב-`sites/afik-gozland/db/schema.sql`). חיבור אומת (`sb_secret_`, ‏200 על כל הטבלאות). אתר סטטי (placeholders מסומנים) live ב-https://afik-gozland.vercel.app, רשום ב-`deployments`. סליקה: Payment Link משולב במצב בדיקה (`plink_1UKKHgJJHpv78gtFfFOOP5md`, ‏₪513) — על חשבון ה-sandbox המשותף `acct_1TvecQJJHpv78gtF` כחריגה זמנית באישור עומר; `#checkout-test` נפרס (`dpl_CWC9bMSnC3pdKV5bh826ERFhauda`). הזרימה הושלמה עד סוף; `projects.status` נשאר `in_progress` בכוונה.
לרקע מלא (ארכיטקטורה, מטרות, שיפורים עתידיים) ראה `docs/project-plan.md`‏.

## על הפרויקט
מערכת סוכנים לבניית אתרים ללקוחות: מבריף פרויקט ועד אתר פרוס עם סליקה. הפרויקט משמש גם עסקית וגם ללימוד עומק של עבודה עם סוכני AI‏.

## מבנה תיקיות
```
.claude/agents/  # הגדרות subagents (roles, prompts, tools)
sites/           # קוד האתרים שנוצרים ללקוחות, תיקייה לכל לקוח
db/              # סכמות SQL, מיגרציות
infra/           # קונפיגורציית פריסה, סקריפטים
```

## מסדי נתונים — אל תערבב ביניהם
1. **DB ראשי (business DB)** — אחד בלבד, מנוהל ב-`db/business-schema.sql`. טבלאות: `clients`, `projects`, `invoices`, `deployments`. זה הדאטהבייס של העסק של המשתמש עצמו.
2. **‏DB לכל לקוח** — נוצר רק אם לאתר יש פונקציונליות דינמית (חנות/הזמנות). שייך פונקציונלית ללקוח, לא לעסק של המשתמש. סכמה בתיקיית הלקוח תחת `sites/<client-name>/db/`‏.

אל תוסיף טבלאות עסקיות של לקוח (מוצרים, הזמנות) ל-DB הראשי, ואל תוסיף נתוני חיוב/פרויקט של המשתמש ל-DB של לקוח.

## סדר בנייה
1. `client-onboarding` — מראיין את המשתמש, קובע template/דרישות DB/דרישות סליקה, ולאחר אישור פותח DB חדש בסופאבייס ללקוח אם נדרש
2. `website-builder` — מייצר אתר סטטי (HTML/Tailwind‏) מ-template מתאים תחת `sites/_template-*/` (landing/ecommerce קיימים, booking טרם נבנה)
3. `deployment` — Vercel/Netlify לסטטי, Docker/VPS לאתרים עם backend; מעדכן `deployments` ב-DB הראשי
4. `billing` — מחבר את חשבון Stripe/Tranzila **של הלקוח** (מפתחות API שהלקוח מספק, לא של המשתמש)

## מוסכמות קוד
- ‏Templates לא נכתבים מאפס בכל פרויקט — משפרים template משותף
- כל פעולה שמשנה כסף/סליקה דורשת אישור מפורש מהמשתמש לפני ביצוע, לא רק לפני תכנון
- אין לגרד (scrape‏) אינסטגרם או פלטפורמות אחרות בניגוד לתנאי השימוש שלהן
- הגדרות סוכנים (`.claude/agents/*.md`‏) נכתבות בעברית בכל הפרוזה (description‏, system prompt‏, טקסט חופשי). שדות YAML טכניים (`name`‏, `tools`‏, `model`‏) ומזהים בפועל (שמות קבצים, טבלאות DB‏) נשארים באנגלית ולא מתורגמים
- כשסוכן צריך לאסוף מידע מהמשתמש בצורה מובנית/מוגבלת (למשל שאלות סגורות בלבד, לא טקסט חופשי) — יש להעדיף כלי שאוכף את זה טכנית (כגון `AskUserQuestion`‏) על פני הסתמכות על כלל בטקסט בלבד, בכל מקום שרלוונטי
- **אין לכתוב סודות (סיסמאות, מפתחות API‏, טוקנים) לשום קובץ זמני, סקראצ'פאד או לוג — בשום שלב, גם לא לרגע ובכוונה למחוק אחר כך.** ערך רגיש שנדרש לפעולה אחת מועבר ישירות בפקודה או במשתנה סביבה של אותה פקודה בלבד. היעד הקבוע היחיד לסודות הוא קובץ `.env` המתאים, שנמצא ב-`.gitignore`

## מגבלת פלטפורמה: subagent לא יכול לשאול את המשתמש
הכלי AskUserQuestion מוסר מכל subagent על ידי Claude Code‏, גם אם הוא רשום במפורש בשדה tools שלו. לכן כל סוכן שתפקידו לראיין את המשתמש — ובראשם client-onboarding — חייב לרוץ בסשן הראשי, ולא להישלח כ-subagent‏.

## מה לא לבנות כרגע
- ‏Remote Control מהאייפון — לא נדרש בשלב זה
- אורקסטרטור — נשקל ונדחה

## Progress tracking
- After finishing a real task (see Git workflow below), update the "מצב נוכחי" section above — a couple of lines on where things stand now, not a growing history.
- This file is the only place status lives; don't duplicate it in `docs/project-plan.md`.
- Refresh the "עדכון אחרון" timestamp (date and time) whenever you touch the section.
- Whenever any agent finishes a task or stops at a gate (success, blocker, or waiting for approval), prepare a short handoff message, clearly marked as ready to copy-paste, containing exactly: (1) what was just done — one or two lines, plain language; (2) current status / which gate you're stopped at, if any; (3) anything the user's other Claude session needs to know to decide what happens next — blockers, decisions made, exact IDs/values relevant to the next step (never secrets themselves); (4) what you expect to do next, once approved/unblocked. Keep it short — a few lines, not a full report duplicate. This is in addition to, not instead of, the detailed report already shown in the session.

## Git workflow
- Commit only at the end of a real project-stage task (agent build, template build, infra work) — one commit per task, tagged per "Commit numbering" below. Wording fixes, doc tweaks, and small maintenance ride along with the next real commit, not their own.
- Money/billing/checkout changes are never auto-committed — always wait for explicit user approval first, regardless of the rule above.
- Never force-push, amend published commits, or run other destructive git operations without explicit request.

### Commit numbering
- `[Stage N, Task M]` prefix — only for commits closing a real project-stage task (agent build, template build, infra work, stage close). Task number is a simple per-stage running counter, following actual execution order.
- Client site work (`sites/<client-name>/`, excluding `sites/_template-*/`) gets no prefix at all — it's operational work tracked in the business DB (`clients`/`projects`/`deployments`), not in commit messages.

### Stage-end tagging
- Once Omer explicitly confirms a stage is done, tag the current commit `stageN-verified`. Client-site polish (real photos, animations) doesn't block this.
