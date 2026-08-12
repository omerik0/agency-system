# CLAUDE.md — הנחיות פרויקט ל-Claude Code

הצב קובץ זה בשורש תיקיית הפרויקט על ה-Mac mini. Claude Code טוען אותו אוטומטית כקונטקסט בכל סשן.

## מצב נוכחי (עדכון אחרון: 12.08.2026 15:10)
- שלב 0 (תשתית): הושלם ✅
- שלב 1 (סוכן בניית אתרים): הושלם ואומת ✅ — tag `stage1-verified`
- שלב 2 (פריסה וסליקה): הושלם ואומת ✅ — tag `stage2-verified`. 5 משימות: סוכני פריסה+סליקה, פריסת test case, ובדיקת קצה-לקצה מלאה (אתר→פריסה→סליקה) על "לק וברק"
- שלב 3 (קליטת לקוחות + הרחבת website-builder): הושלם, כולל בדיקת קצה-לקצה מלאה (client-onboarding → website-builder → deployment → billing) על לקוח-דמה חדש ("חנות דמה", template ecommerce). **ממתין לאישור סופי של עומר לפני תיוג `stage3-verified`.** `_template-booking` נשאר מתועד כאופציה עתידית, טרם נבנה — לא חוסם
- לקוח אמיתי ראשון דרך `/newclient`: גיא שטאובר (`sites/guy-stauber/`, template ecommerce). ראיון client-onboarding הושלם ואושר; DB ב-Supabase נפתח בפועל (`products`/`customers`/`orders`, RLS מופעל, policy ציבורי ל-`products` בלבד). **עוצר כאן וממתין לאישור עומר לפני מעבר לסוכן בניית האתרים.**
- לפרטים והיסטוריה מלאה ראה `docs/project-plan.md`

## על הפרויקט
מערכת סוכנים לבניית אתרים ללקוחות: מבריף פרויקט ועד אתר פרוס עם סליקה. הפרויקט משמש גם עסקית וגם ללימוד עומק של עבודה עם סוכני AI.

## מבנה תיקיות
```
.claude/agents/  # הגדרות subagents (roles, prompts, tools)
sites/           # קוד האתרים שנוצרים ללקוחות, תיקייה לכל לקוח
db/              # סכמות SQL, מיגרציות
infra/           # קונפיגורציית פריסה, סקריפטים
```

## מסדי נתונים — אל תערבב ביניהם
1. **DB ראשי (business DB)** — אחד בלבד, מנוהל ב-`db/business-schema.sql`. טבלאות: `clients`, `projects`, `invoices`, `deployments`. זה הדאטהבייס של העסק של המשתמש עצמו.
2. **DB לכל לקוח** — נוצר רק אם לאתר יש פונקציונליות דינמית (חנות/הזמנות). שייך פונקציונלית ללקוח, לא לעסק של המשתמש. סכמה בתיקיית הלקוח תחת `sites/<client-name>/db/`.

אל תוסיף טבלאות עסקיות של לקוח (מוצרים, הזמנות) ל-DB הראשי, ואל תוסיף נתוני חיוב/פרויקט של המשתמש ל-DB של לקוח.

## סדר בנייה
1. סוכן קליטת לקוחות — מראיין את המשתמש (לא את הלקוח) בשאלות מובנות, קובע template/דרישות DB/דרישות סליקה, ולאחר אישור — פותח DB חדש בסופאבייס ללקוח אם נדרש
2. סוכן בניית אתרים — מקבל בריף, מייצר אתר סטטי (HTML/Tailwind) מ-template בסיס תחת `sites/_template-*/` (landing/ecommerce/booking — הסוג נקבע על ידי סוכן הקליטה)
3. סוכן פריסה — Vercel/Netlify לסטטי, Docker/VPS לאתרים עם backend; מעדכן `deployments` ב-DB הראשי
4. סוכן סליקה — מחבר את חשבון Stripe/Tranzila **של הלקוח** (מפתחות API שהלקוח מספק, לא של המשתמש)

## מוסכמות קוד
- Templates לא נכתבים מאפס בכל פרויקט — משפרים template משותף
- כל פעולה שמשנה כסף/סליקה דורשת אישור מפורש מהמשתמש לפני ביצוע, לא רק לפני תכנון
- אין לגרד (scrape) אינסטגרם או פלטפורמות אחרות בניגוד לתנאי השימוש שלהן
- הגדרות סוכנים (`.claude/agents/*.md`) נכתבות בעברית בכל הפרוזה (description, system prompt, טקסט חופשי). שדות YAML טכניים (`name`, `tools`, `model`) ומזהים בפועל (שמות קבצים, טבלאות DB) נשארים באנגלית ולא מתורגמים
- כשסוכן צריך לאסוף מידע מהמשתמש בצורה מובנית/מוגבלת (למשל שאלות סגורות בלבד, לא טקסט חופשי) — יש להעדיף כלי שאוכף את זה טכנית (כגון `AskUserQuestion`) על פני הסתמכות על כלל בטקסט בלבד, בכל מקום שרלוונטי
- **אין לכתוב סודות (סיסמאות, מפתחות API, טוקנים) לשום קובץ זמני, סקראצ'פאד או לוג — בשום שלב, גם לא לרגע ובכוונה למחוק אחר כך.** ערך רגיש שנדרש לפעולה אחת מועבר ישירות בפקודה או במשתנה סביבה של אותה פקודה בלבד. היעד הקבוע היחיד לסודות הוא קובץ `.env` המתאים, שנמצא ב-`.gitignore`

## מגבלת פלטפורמה: subagent לא יכול לשאול את המשתמש
הכלי AskUserQuestion מוסר מכל subagent על ידי Claude Code, גם אם הוא רשום במפורש בשדה tools שלו. לכן כל סוכן שתפקידו לראיין את המשתמש — ובראשם client-onboarding — חייב לרוץ בסשן הראשי, ולא להישלח כ-subagent.

## מה לא לבנות כרגע
- Remote Control מהאייפון — לא נדרש בשלב זה
- אורקסטרטור — נשקל ונדחה

## Progress tracking
- After completing any task, update the "מצב נוכחי" section in both `CLAUDE.md` and `docs/project-plan.md`:
  - Mark the completed task as done.
  - Add one line stating the current stage number and task name (e.g. "Stage 1, Task: rich brief testing — in progress").
- Do this automatically, without being asked, as part of finishing the task — before or together with the git commit.
- Refresh the "עדכון אחרון" timestamp at the top of the section to the current date AND time (not just date) every time the section is updated.
- Keep "מצב נוכחי" lean, not additive: when marking something done or updating progress, remove or condense outdated/completed notes instead of appending new lines on top of old ones. Keep only what's still relevant to understanding the current state. Move historical detail worth preserving to a separate changelog section (`docs/project-plan.md` has one), not the main status view.

## Git workflow
- After finishing any working piece of code, automatically create a git commit with a clear English commit message — do not wait to be asked.
- This does not apply to changes that touch money/billing/checkout — those still require explicit user approval before any action, per the code conventions above, and should not be auto-committed without that approval.
- Never force-push, amend published commits, or run other destructive git operations without explicit request, regardless of this auto-commit instruction.

### Commit numbering
- פרפיקס `[Stage N, Task M]` שמור **אך ורק לאבני דרך אמיתיות בשלבי הפרויקט**: בניית סוכן, בניית template, הקמת תשתית, סגירת שלב. לא כל שמירה. דוגמה: `[Stage 1, Task 5] Add pastries section to pinat-uri site`.
- מספר המשימה הוא מונה רץ פשוט לכל שלב (Task 1, 2, 3...), מתקדם לפי סדר הביצוע בפועל — אין רשימת TODO ממוספרת נפרדת שצריך להתאים אליה.
- **תיקוני ניסוח, הבהרות תיעודיות, עדכוני מוסכמות, ותחזוקה קטנה — הודעת commit רגילה באנגלית, בלי שום פרפיקס.** (הכלל הקודם, שחייב פרפיקס גם על עדכוני תיעוד/ניקיון, מבוטל.)
- **עבודה על אתר של לקוח (בתיקיית `sites/<client-name>/`, לא כולל `sites/_template-*/`) גם היא ללא שום פרפיקס** — לא מספר שלב/משימה, וגם לא `[Client: ...]`. היא עבודה שוטפת (operational work), לא אבן דרך בפיתוח המערכת עצמה, והמעקב אחרי לקוחות נעשה במסד הנתונים הראשי (`clients`/`projects`/`deployments`) — לא בהודעות ה-commit.
  - הכלל נקבע לפי **מה שהקומיט משנה בפועל**, לא לפי מה שהניע אותו: קומיט שמשנה רק קבצים תחת `sites/<client-name>/` (כולל ה-DB הייעודי שלו) יוצא ללא פרפיקס. קומיט שמייצג אבן דרך אמיתית בעבודה על המערכת עצמה (`.claude/agents/*.md` חדש/משמעותי, template חדש, תשתית, סגירת שלב) מקבל `[Stage N, Task M]` — **גם אם** הוא נכתב כתוצאה מעבודה על לקוח ספציפי. כל שאר עדכוני התיעוד/המוסכמות/התחזוקה על המערכת — בלי פרפיקס, לפי הכלל שלמעלה. קומיט שמערבב סוגים שונים יפוצל לכמה קומיטים נפרדים.

### Stage-end tagging
- At the end of each completed stage, once Omer (the manager) explicitly confirms it's done, create a git tag named `stageN-verified` on the current commit.
- Images/polish for client sites (real client photos, transitions/animations, etc.) are tracked as future enhancements — they do not block marking a stage complete or creating its verification tag.
