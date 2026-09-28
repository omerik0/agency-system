# ‏`CLAUDE.md` — הנחיות פרויקט ל-Claude Code

## מצב נוכחי (עדכון אחרון: 28.09.2026 14:24)
- שלב 0 — תשתית: תיקיית הפרויקט, git, DB ראשי ב-Supabase ✅
- שלב 1 — סוכן בניית אתרים (`website-builder` + template landing‏) ✅ `stage1-verified`
- שלב 2 — סוכני פריסה וסליקה (`deployment`‏, `billing`‏) ✅ `stage2-verified`
- שלב 3 — קליטת לקוחות (`client-onboarding`‏) והרחבת `website-builder` לכמה templates ✅ `stage3-verified`

בתיקיית `sites/`‏: התבניות `_template-*` ושני אתרי בדיקה — `lak-ve-varak` ו-`afik-gozland`‏.

## על הפרויקט
מערכת סוכנים לבניית אתרים ללקוחות: מבריף פרויקט ועד אתר פרוס עם סליקה. הפרויקט משמש גם עסקית וגם ללימוד עומק של עבודה עם סוכני AI‏.

## מבנה תיקיות
```
.claude/agents/  # הגדרות subagents (roles, prompts, tools)
sites/           # קוד האתרים שנוצרים ללקוחות, תיקייה לכל לקוח
db/              # סכמות SQL, מיגרציות
docs/            # תוכנית הפרויקט: מטרה, ארכיטקטורה, מודל אבטחה, מגבלות
infra/           # קונפיגורציית פריסה, סקריפטים
```

## מסדי נתונים — אל תערבב ביניהם
1. **DB ראשי (business DB)** — אחד בלבד, מנוהל ב-`db/business-schema.sql`. טבלאות: `clients`, `projects`, `invoices`, `deployments`. זה הדאטהבייס של העסק של המשתמש עצמו.
2. **‏DB לכל לקוח** — נוצר רק אם לאתר יש פונקציונליות דינמית (חנות/הזמנות). שייך פונקציונלית ללקוח, לא לעסק של המשתמש. סכמה בתיקיית הלקוח תחת `sites/<client-name>/db/`‏.

אל תוסיף טבלאות עסקיות של לקוח (מוצרים, הזמנות) ל-DB הראשי, ואל תוסיף נתוני חיוב/פרויקט של המשתמש ל-DB של לקוח.

## זרימת הסוכנים
1. ‏`client-onboarding` — מראיין את המשתמש, קובע template/דרישות DB/דרישות סליקה, ולאחר אישור פותח DB חדש בסופאבייס ללקוח אם נדרש
2. ‏`website-builder` — מייצר אתר סטטי (HTML/Tailwind‏) מ-template מתאים תחת `sites/_template-*/` (landing/ecommerce קיימים, booking טרם נבנה)
3. ‏`deployment` — פורס את האתר הסטטי ל-Vercel ומעדכן `deployments` ב-DB הראשי
4. ‏`billing` — מחבר את חשבון ה-Stripe **של הלקוח** (מפתחות API שהלקוח מספק, לא של המשתמש)

## מוסכמות קוד
- ‏Templates לא נכתבים מאפס בכל פרויקט — משפרים template משותף
- כל פעולה שמשנה כסף/סליקה דורשת אישור מפורש מהמשתמש לפני ביצוע, לא רק לפני תכנון
- הגדרות סוכנים (`.claude/agents/*.md`‏) נכתבות בעברית בכל הפרוזה (description‏, system prompt‏, טקסט חופשי). שדות YAML טכניים (`name`‏, `tools`‏, `model`‏) ומזהים בפועל (שמות קבצים, טבלאות DB‏) נשארים באנגלית ולא מתורגמים
- איסוף מידע מובנה מהמשתמש — בכלי שאוכף זאת טכנית (`AskUserQuestion`‏), לא בכלל טקסט; ראו "מגבלת פלטפורמה" למטה
- **אין לכתוב סודות (סיסמאות, מפתחות API‏, טוקנים) לשום קובץ זמני, סקראצ'פאד או לוג — בשום שלב, גם לא לרגע ובכוונה למחוק אחר כך.** ערך רגיש שנדרש לפעולה אחת מועבר ישירות בפקודה או במשתנה סביבה של אותה פקודה בלבד. היעד הקבוע היחיד לסודות הוא קובץ `.env` המתאים, שנמצא ב-`.gitignore`

## קבצי `.env`
- ה-`.env` בשורש מחזיק את סודות העסק (DB ראשי, טוקן Supabase ברמת ארגון, טוקן Vercel‏); ‏`sites/<client>/.env` מחזיק רק את המפתחות של אותו לקוח. לעולם לא לטעון את הקובץ הלא-נכון לפעולה.
- פריסה ל-production תמיד דורשת אישור מפורש — נאכף על ידי כלל ה-`ask` על `vercel deploy` ב-`.claude/settings.json`‏.

## מגבלת פלטפורמה: subagent לא יכול לשאול את המשתמש
הכלי AskUserQuestion מוסר מכל subagent על ידי Claude Code‏, גם אם הוא רשום במפורש בשדה tools שלו. לכן כל סוכן שתפקידו לראיין את המשתמש — ובראשם client-onboarding — חייב לרוץ בסשן הראשי, ולא להישלח כ-subagent‏.

## Progress tracking
- After finishing a task (see Git workflow below), update the "מצב נוכחי" section above — the per-stage checklist and the one-line summary of `sites/`; current state only, not a growing history.
- This file is the only place status lives; don't duplicate it in `docs/project-plan.md`.
- Refresh the "עדכון אחרון" timestamp (date and time) whenever you touch the section.
- Whenever any agent finishes a task or stops at a gate (success, blocker, or waiting for approval), prepare a short handoff message, clearly marked as ready to copy-paste, containing exactly: (1) what was just done — one or two lines, plain language; (2) current status / which gate you're stopped at, if any; (3) anything the user's other Claude session needs to know to decide what happens next — blockers, decisions made, exact IDs/values relevant to the next step (never secrets themselves); (4) what you expect to do next, once approved/unblocked. Keep it short — a few lines, not a full report duplicate. This is in addition to, not instead of, the detailed report already shown in the session.

## Git workflow
- Commit at the end of every completed task — stage task, client work, or cleanup. One commit per task.
- Small doc/wording fixes ride along with the next commit, not their own.
- Money/billing/checkout changes are never auto-committed — always wait for explicit user approval first, regardless of the rules above.
- Before any push to a remote, commit everything pending.
- Never force-push, amend published commits, or run other destructive git operations without explicit request.

### Commit numbering
- `[Stage N, Task M]` prefix — only for stage tasks (agent build, template build, infra work, stage close). Task number is a simple per-stage running counter, following actual execution order.
- Everything else — client site work (`sites/<client-name>/`, excluding `sites/_template-*/`), cleanup, maintenance — gets no prefix. Client work is tracked in the business DB (`clients`/`projects`/`deployments`), not in commit messages.

### Stage-end tagging
- Once Omer explicitly confirms a stage is done, tag the current commit `stageN-verified`. Client-site polish (real photos, animations) doesn't block this.
