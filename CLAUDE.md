# CLAUDE.md — הנחיות פרויקט ל-Claude Code

הצב קובץ זה בשורש תיקיית הפרויקט על ה-Mac mini. Claude Code טוען אותו אוטומטית כקונטקסט בכל סשן.

## מצב נוכחי (עדכון אחרון: 21.07.2026)
- שלב 0 (תשתית) הושלם במלואו: git, מבנה תיקיות, business DB schema קיים ב-`db/`, ו-DB בפועל ב-Supabase נוצר ואומת — כל 4 הטבלאות (`clients`, `projects`, `invoices`, `deployments`) קיימות ונראות ב-Table Editor, RLS מופעל
- שלב 1 (סוכן בניית אתרים) בתהליך: `sites/_template/index.html` קיים, אתר לקוח ראשון לדוגמה `sites/lak-ve-varak/index.html` נבנה בהצלחה כולל תמיכת RTL ועברית (פונט Heebo)
- שלב 1, משימה: בדיקת בריף עשיר (תוכן אמיתי, צבעי מותג ספציפיים) — הושלמה בהצלחה עם `sites/pinat-uri/index.html` (בית קפה בוטיק), כולל התאמת צבעי מותג מותאמים אישית (טרקוטה/קרם/אספרסו) ותוכן ספציפי בכל סקציה
- טרם עברנו לשלב 2 (פריסה וסליקה) — עדיין משפרים ובודקים את סוכן בניית האתרים
- לפרטים מלאים ראה `docs/project-plan.md`

## על הפרויקט
מערכת סוכנים לבניית אתרים ללקוחות: מבריף פרויקט ועד אתר פרוס עם סליקה. הפרויקט משמש גם עסקית וגם ללימוד עומק של עבודה עם סוכני AI.

**שלב נוכחי: סוכן איתור הלידים מושהה — אין לבנות אותו כרגע. מתמקדים בסוכן בניית אתרים, סוכן פריסה/סליקה, והאורקסטרטור.**

## מבנה תיקיות
```
.claude/agents/  # הגדרות subagents (roles, prompts, tools)
sites/           # קוד האתרים שנוצרים ללקוחות, תיקייה לכל לקוח
db/              # סכמות SQL, מיגרציות
infra/           # קונפיגורציית פריסה, סקריפטים
```

## מסדי נתונים — אל תערבב ביניהם
1. **DB ראשי (business DB)** — אחד בלבד, מנוהל ב-`db/business/`. טבלאות: `clients`, `projects`, `invoices`, `deployments`. זה הדאטהבייס של העסק של המשתמש עצמו.
2. **DB לכל לקוח** — נוצר רק אם לאתר יש פונקציונליות דינמית (חנות/הזמנות). שייך פונקציונלית ללקוח, לא לעסק של המשתמש. סכמה בתיקיית הלקוח תחת `sites/<client-name>/db/`.

אל תוסיף טבלאות עסקיות של לקוח (מוצרים, הזמנות) ל-DB הראשי, ואל תוסיף נתוני חיוב/פרויקט של המשתמש ל-DB של לקוח.

## סדר בנייה
1. סוכן בניית אתרים — מקבל בריף, מייצר דף נחיתה סטטי (HTML/Tailwind) מ-template בסיס ב-`sites/_template/`
2. סוכן פריסה — Vercel/Netlify לסטטי, Docker/VPS לאתרים עם backend; מעדכן `deployments` ב-DB הראשי
3. סוכן סליקה — מחבר את חשבון Stripe/Tranzila **של הלקוח** (מפתחות API שהלקוח מספק, לא של המשתמש)
4. אורקסטרטור — subagent שמתאם: פרויקט חדש → בניית אתר → אישור משתמש → פריסה → סליקה → עדכון סטטוס ב-`projects`

## מוסכמות קוד
- Templates לא נכתבים מאפס בכל פרויקט — משפרים template משותף
- כל פעולה שמשנה כסף/סליקה דורשת אישור מפורש מהמשתמש לפני ביצוע, לא רק לפני תכנון
- אין לגרד (scrape) אינסטגרם או פלטפורמות אחרות בניגוד לתנאי השימוש שלהן

## מה לא לבנות כרגע
- סוכן איתור לידים / Meta Graph API — יטופל בנפרד, בהמשך
- Remote Control מהאייפון — לא נדרש בשלב זה

## Progress tracking
- After completing any task, update the "מצב נוכחי" section in both `CLAUDE.md` and `docs/project-plan.md`:
  - Mark the completed task as done.
  - Add one line stating the current stage number and task name (e.g. "Stage 1, Task: rich brief testing — in progress").
- Do this automatically, without being asked, as part of finishing the task — before or together with the git commit.

## Git workflow
- After finishing any working piece of code, automatically create a git commit with a clear English commit message — do not wait to be asked.
- This does not apply to changes that touch money/billing/checkout — those still require explicit user approval before any action, per the code conventions above, and should not be auto-committed without that approval.
- Never force-push, amend published commits, or run other destructive git operations without explicit request, regardless of this auto-commit instruction.

### Commit numbering
- Every commit message must be prefixed with the current stage and task number from the "מצב נוכחי" section, e.g. `[Stage 1, Task 5] Add pastries section to pinat-uri site`.
- The task number is a simple sequential counter per stage (Task 1, 2, 3...), incremented in the order work is actually done — there is no separate formal numbered TODO list to match against.
- General/meta commits that aren't tied to a specific stage's deliverables (e.g. editing this file's workflow conventions) may omit the prefix.
