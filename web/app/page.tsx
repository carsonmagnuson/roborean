import { db } from "@/db";
import { words } from "@/db/schema";
import { addWord, deleteWord } from "./actions";
import { getScore } from "@/lib/score";

export const dynamic = "force-dynamic"; //to obviate the query-prerendering issue, apparently.

export function tierStyles(score: number | null): string {
    if (score === null) return "border-l-amber-400 text-amber-300";      // lost
    if (score < 3) return "border-l-neutral-500 text-neutral-400";       // common
    if (score < 5) return "border-l-green-500 text-green-300";           // uncommon
    if (score < 6.5) return "border-l-blue-500 text-blue-300";           // rare
    return "border-l-violet-500 text-violet-300";                         // mythic
}

export default async function Home() {
  const allWords = await db.select().from(words);
  const scored = await Promise.all(
    allWords.map(async (entry) => ({
      ...entry,
      score: await getScore(entry.word),
    }))
  );


  return (
    <main className="max-w-2xl mx-auto p-8">
      <h1 className="text-8xl font-serif mb-2">ROBOREAN</h1>
      <p className="text-sm text-gray-500 mb-6">{allWords.length} words saved</p>
      <form action={addWord} className="mb-8 flex flex-col gap-2">
        <input
          name="word"
          placeholder="word"
          required
          className="border border-gray-300 rounded p-2"
        />
        <button
          type="submit"
          className="bg-gray-900 text-white hover:bg-gray-600 rounded p-2 font-semibold">
          Add word
        </button>
      </form>
      <ul className="space-y-3">
        {scored.map((entry) => (
          <li
            key={entry.id}
            className={`p-4 rounded-lg border ${tierStyles(entry.score)} flex items-start justify-between gap-4`}>
            <div>
              <strong className="text-5xl font-serif">
                {entry.word}

                {entry.score !== null && (
                  <span className="ml-2 rounded-full bg-violet-900 px-2 py-0.5 text-xs font-mono text-violet-200">
                    {entry.score.toFixed(1)}
                  </span>
                )}
              </strong>
              <p className="text-gray-600">{entry.meaning}</p>
            </div>
            <form action={deleteWord}>
              <input type="hidden" name="id" value={entry.id} />
              <button
                type="submit"
                className="text-sm text-red-600 hover:text-red-800">
                delete
              </button>
            </form>
          </li>
        ))}
      </ul>
    </main>
  );
}
