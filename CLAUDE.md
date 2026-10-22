# ‏`CLAUDE.md` — הנחיות פרויקט ל-Claude Code

## מצב נוכחי (עדכון אחרון: 22.10.2026 16:20)
- שלב 0 — תשתית: תיקיית הפרויקט, git, DB ראשי ב-Supabase ✅
- שלב 1 — סוכן בניית אתרים (`website-builder` + template landing‏) ✅ `stage1-verified`
- שלב 2 — סוכני פריסה וסליקה (`deployment`‏, `billing`‏) ✅ `stage2-verified`
- שלב 3 — קליטת לקוחות (`client-onboarding`‏) והרחבת `website-builder` לכמה templates ✅ `stage3-verified`
- שלב 4 — פאנל ניהול לבעל החנות: מתוכנן, טרם החל (פירוט ב-`docs/project-plan.md`‏)
- שלב 5 — הזמנות וצ'קאאוט: מתוכנן, טרם החל (פירוט ב-`docs/project-plan.md`‏)
- משימות פתוחות: ראו `docs/project-plan.md`‏
- סבב עיצוב בעיצומו: ספריית האפקטים נבנתה ב-`_template-landing`‏, והשאר ממתין לאישור (ראו `docs/project-plan.md`‏)

בריפו, תחת `sites/`‏: התבניות `_template-*` ושני אתרי בדיקה — `lak-ve-varak` ו-`afik-gozland`‏. אתרי לקוחות אמיתיים נמצאים רק במחשב הזה ובגיבוי הפרטי ב-Drive‏, ולא מוזכרים בשמם במסמכים ציבוריים.

הריפו ציבורי ב-GitHub‏: https://github.com/omerik0/agency-system ‏(`main` + התגים `stage1/2/3-verified`).

## על הפרויקט
מערכת סוכנים לבניית אתרים ללקוחות: מבריף פרויקט ועד אתר פרוס עם סליקה. הפרויקט משמש גם עסקית וגם ללימוד עומק של עבודה עם סוכני AI‏.

## מבנה תיקיות
```
.claude/agents/  # הגדרות subagents (roles, prompts, tools)
sites/           # תבניות ואתרי בדיקה בריפו; אתרי לקוחות אמיתיים מקומיים בלבד
db/              # סכמות SQL, מיגרציות
docs/            # תוכנית הפרויקט: מטרה, ארכיטקטורה, מודל אבטחה, מגבלות
tools/           # סקריפטים קטנים לאימות (למשל youtube_id.py)
```

## מסדי נתונים — אל תערבב ביניהם
1. **DB ראשי (business DB)** — אחד בלבד, מנוהל ב-`db/business-schema.sql`. טבלאות: `clients`, `projects`, `invoices`, `deployments`. זה הדאטהבייס של העסק של המשתמש עצמו.
2. **‏DB לכל לקוח** — נוצר רק אם לאתר יש פונקציונליות דינמית (חנות/הזמנות). שייך פונקציונלית ללקוח, לא לעסק של המשתמש. סכמה בתיקיית הלקוח תחת `sites/<client-name>/db/`‏.

אל תוסיף טבלאות עסקיות של לקוח (מוצרים, הזמנות) ל-DB הראשי, ואל תוסיף נתוני חיוב/פרויקט של המשתמש ל-DB של לקוח.

## זרימת הסוכנים
1. ‏`client-onboarding` — מראיין את המשתמש, קובע template/דרישות DB/דרישות סליקה, ולאחר אישור פותח DB חדש בסופאבייס ללקוח אם נדרש. רץ בסשן הראשי (`.claude/agents/client-onboarding.md`‏)
2. ‏`website-builder` — מייצר אתר סטטי (HTML/Tailwind‏) מ-template מתאים תחת `sites/_template-*/` (landing/ecommerce קיימים, booking טרם נבנה), ומטפל במדיה של הלקוח. רץ כ-subagent (`.claude/agents/website-builder.md`‏)
3. ‏`deployment` — פורס את האתר הסטטי ל-Vercel ומעדכן `deployments` ב-DB הראשי. רץ כ-subagent (`.claude/agents/deployment.md`‏)
4. ‏`billing` — מחבר את חשבון ה-Stripe **של הלקוח** (מפתחות API שהלקוח מספק, לא של המשתמש). רץ כ-subagent (`.claude/agents/billing.md`‏)

**שלב שאלות המדיה** — רץ בסשן הראשי בתוך `/newclient`‏, אחרי שהמשתמש מאשר את הבנייה ולפני שמפעילים את `website-builder`‏. הפירוט ב-`.claude/commands/newclient.md`‏.

**המצבים של `website-builder`‏** — `initial`‏, ‏`update` ו-`apply-decisions`‏. הסשן הראשי קובע את המצב בבריף, והכללים המלאים נמצאים רק ב-`.claude/agents/website-builder.md`‏.

**זרימת `/updatesite`** — הסשן הראשי מאתר את המדיה של הלקוח, מציג את מצב האתר, שואל מה מעדכנים (מדיה, קישורי יוטיוב, תוכן), מפעיל את `website-builder` במצב `update` (ו-`apply-decisions` לפי הצורך), ועוצר לאישור המשתמש לפריסה מחדש ל-production לפני שמפעיל את `deployment`‏. הפירוט ב-`.claude/commands/updatesite.md`‏.

**תבנית הנחיתה** — ‏`sites/_template-landing/` היא בסיס מודרני בעברית (משתני צבע, גלריה לפי מספר התמונות, קרוסלת סרטונים, סקשנים אופציונליים עם `data-section`‏). כללי העיצוב נמצאים רק ב-`website-builder.md`‏.

**בדיקה חזותית** — אחרי הדוח של `website-builder` ולפני שער הפריסה: אם לסשן הראשי יש דרך להציג דף (דפדפן או כלי תצוגה; לא מתקינים כלום), פותחים את `index.html` המקומי ברוחב 1440px וברוחב 390px‏, מסתכלים, ומפרטים בעיות חזותיות קונקרטיות (סימטריה, ריווח, ניגודיות, גלישה, מדיה שבורה). מעבירים אותן ל-`website-builder` לסבב תיקון אחד. אם אין דרך להציג — כותבים זאת בדוח ומדלגים.

**פקודות**
- ‏`/newclient` — קליטת לקוח חדש, מהראיון ועד לפריסה, עם עצירה בכל שער (`.claude/commands/newclient.md`‏)
- ‏`/updatesite` — עדכון אתר של לקוח קיים: מדיה ותוכן (`.claude/commands/updatesite.md`‏)

**כלים** — ‏`tools/youtube_id.py` מאמת קישור YouTube ומדפיס את ה-id. משתמשים בו `website-builder` (לפני הטמעה) ו-`deployment` (בדיקה אחרי פריסה); אף סוכן אחר לא מפרק קישורי YouTube בעצמו.

## מוסכמות קוד
- ‏Templates לא נכתבים מאפס בכל פרויקט — משפרים template משותף
- כל פעולה שמשנה כסף/סליקה דורשת אישור מפורש מהמשתמש לפני ביצוע, לא רק לפני תכנון
- הגדרות סוכנים (`.claude/agents/*.md`‏) נכתבות בעברית בכל הפרוזה (description‏, system prompt‏, טקסט חופשי). שדות YAML טכניים (`name`‏, `tools`‏, `model`‏) ומזהים בפועל (שמות קבצים, טבלאות DB‏) נשארים באנגלית ולא מתורגמים
- מקורות המדיה של הלקוחות נמצאים ב-Google Drive‏ (`agency-system/<client>/originals/`‏), מחוץ לריפו. בפרויקט נמצאות רק גרסאות הווב הדחוסות, והן לא נכנסות ל-commit.
- אתרי לקוחות אמיתיים לא נכנסים לעולם ל-commit בריפו הזה או בשום remote‏. ‏`.gitignore` מחריג את כל `sites/*/` חוץ מהתבניות ושני אתרי הבדיקה.
- לכל אתר לקוח אמיתי יש ריפו git מקומי משלו בתוך התיקייה שלו, לצורך undo‏, בלי remote‏. הסשן הראשי מבצע בו commit (`git -C sites/<client>`‏) אחרי כל שלב שהושלם ושינה את האתר: בנייה ראשונה, כל שינוי של `/updatesite` ופריסה. שינויי סליקה נכנסים ל-commit רק באישור המשתמש, כמו היום.
- אחרי כל פריסה הסשן הראשי מעתיק את תיקיית האתר ל-`<media root>/<client>/site-backup/` עם `rsync -a`‏, בלי `--delete`‏, ומחריג את `.env*`‏, ‏`.vercel` ו-`.git`‏. את ה-media root מאתרים כמו שמתואר ב-`client-onboarding.md`‏. לעולם לא מוחקים שום דבר ב-Drive‏.
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
- Every main-session response that ends a turn ends with a handoff block — including answers to simple questions, read-only commands and reports. Never skip it because the answer is short.
  - Format: the very last thing in the response, one fenced code block whose first line is `HANDOFF: <short topic>`, followed by exactly four fields, each a short paragraph (about 12 lines total): `Done:` (what was just done), `Status:` (current state, and the gate you're stopped at, if any), `Context:` (what the user's other chat needs: IDs, decisions, blockers — never secrets or full Drive paths), `Next:` (what you expect to do once approved/unblocked). The block is plain English; the report above it is in Hebrew.
  - Self-contained: never write "as shown above", "same as before", or otherwise refer to earlier output.
  - When the user asks for exact text or raw command output, print it in full in a code block in the report, before the handoff block. A description or summary is not an answer.
  - Subagents report to the main session; only the main session writes the handoff block.

## Git workflow
- Commit at the end of every completed task — stage task or cleanup. One commit per task. Real client work is committed in the client's own local repo (see Commit numbering).
- Small doc/wording fixes ride along with the next commit, not their own.
- Money/billing/checkout changes are never auto-committed — always wait for explicit user approval first, regardless of the rules above.
- Before any push to a remote, commit everything pending.
- Never force-push, amend published commits, or run other destructive git operations without explicit request.

### Commit numbering
- `[Stage N, Task M]` prefix — only for stage tasks (agent build, template build, infra work, stage close). Task number is a simple per-stage running counter, following actual execution order.
- Everything else in this repo — cleanup, maintenance, demo-site work — gets no prefix.
- Real client site work is never committed here: it goes into the client's own local repo (`git -C sites/<client-name>`, no remote). Client work is tracked in the business DB (`clients`/`projects`/`deployments`), and client names never appear in this repo's commit messages.

### Stage-end tagging
- Once Omer explicitly confirms a stage is done, tag the current commit `stageN-verified`. Client-site polish (real photos, animations) doesn't block this.
